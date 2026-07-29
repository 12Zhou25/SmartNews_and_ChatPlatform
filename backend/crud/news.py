from sqlalchemy import select, func, update, or_
from sqlalchemy.ext.asyncio import AsyncSession
from models.news import Category, News


async def get_categories(db: AsyncSession, skip: int = 0, limit: int = 100):
    stmt = select(Category).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


async def get_news_list(db: AsyncSession, category_id: int, skip: int = 0, limit: int = 10):
    # 查询的是指定分类下的所有新闻
    stmt = select(News).where(News.category_id == category_id).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


async def get_news_count(db: AsyncSession, category_id: int):
    # 查询的是指定分类下的新闻数量
    stmt = select(func.count(News.id)).where(News.category_id == category_id)
    result = await db.execute(stmt)
    return result.scalar_one()  # 只能有一个结果，否则报错


async def get_news_detail(db: AsyncSession, news_id: int):
    stmt = select(News).where(News.id == news_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def increase_news_views(db: AsyncSession, news_id: int):
    stmt = update(News).where(News.id == news_id).values(views=News.views + 1)
    result = await db.execute(stmt)
    await db.commit()

    # 更新 → 检查数据库是否真的命中了数据 → 命中了返回True
    return result.rowcount > 0


async def get_related_news(db: AsyncSession, news_id: int, category_id: int, limit: int = 5):
    # order_by 排序 → 浏览量和发布时间
    stmt = select(News).where(
        News.category_id == category_id,
        News.id != news_id
    ).order_by(
        News.views.desc(),  # 默认是升序，desc 表示降序
        News.publish_time.desc()
    ).limit(limit)
    result = await db.execute(stmt)
    # return result.scalars().all()
    related_news = result.scalars().all()
    # 列表推导式 推导出新闻的核心数据，然后再 return
    return [{
        "id": news_detail.id,
        "title": news_detail.title,
        "content": news_detail.content,
        "image": news_detail.image,
        "author": news_detail.author,
        "publishTime": news_detail.publish_time,
        "categoryId": news_detail.category_id,
        "views": news_detail.views
    } for news_detail in related_news]


async def search_news(db: AsyncSession, keyword: str, page: int = 1, page_size: int = 10):
    """按关键词搜索新闻（标题+内容）"""
    pattern = f"%{keyword}%"
    offset = (page - 1) * page_size

    # 搜索标题或内容匹配的新闻
    stmt = select(News).where(
        or_(News.title.ilike(pattern), News.content.ilike(pattern))
    ).order_by(News.views.desc(), News.publish_time.desc()).offset(offset).limit(page_size)
    result = await db.execute(stmt)
    news_list = result.scalars().all()

    # 计算总数
    count_stmt = select(func.count(News.id)).where(
        or_(News.title.ilike(pattern), News.content.ilike(pattern))
    )
    count_result = await db.execute(count_stmt)
    total = count_result.scalar_one()

    return news_list, total


async def get_hot_news(db: AsyncSession, limit: int = 20):
    """获取热门新闻（按浏览量降序）"""
    stmt = select(News).order_by(News.views.desc(), News.publish_time.desc()).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


async def get_latest_news(db: AsyncSession, limit: int = 20):
    """获取最新新闻（按发布时间降序）"""
    stmt = select(News).order_by(News.publish_time.desc()).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()
