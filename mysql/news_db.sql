-- ============================================================
-- FastAPI-LLM 新闻数据库初始化 SQL
-- 数据库名: news_db
-- 字符集: utf8mb4
-- 用法: mysql -u root -p < news_db.sql
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS news_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE news_db;

-- ============================================================
-- 1. 新闻分类表
-- ============================================================
CREATE TABLE IF NOT EXISTS news_category (
    id         INT          NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    name       VARCHAR(50)  NOT NULL COMMENT '分类名称',
    sort_order INT          NOT NULL DEFAULT 0 COMMENT '排序',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='新闻分类表';

-- ============================================================
-- 2. 新闻表
-- ============================================================
CREATE TABLE IF NOT EXISTS news (
    id           INT          NOT NULL AUTO_INCREMENT COMMENT '新闻ID',
    title        VARCHAR(255) NOT NULL COMMENT '新闻标题',
    description  VARCHAR(500)          COMMENT '新闻简介',
    content      TEXT         NOT NULL COMMENT '新闻内容',
    image        VARCHAR(255)          COMMENT '封面图片URL',
    author       VARCHAR(50)           COMMENT '作者',
    category_id  INT          NOT NULL COMMENT '分类ID',
    views        INT          NOT NULL DEFAULT 0 COMMENT '浏览量',
    publish_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    INDEX idx_category (category_id),
    INDEX idx_publish_time (publish_time),
    CONSTRAINT fk_news_category FOREIGN KEY (category_id) REFERENCES news_category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='新闻文章表';

-- ============================================================
-- 3. 用户表
-- ============================================================
CREATE TABLE IF NOT EXISTS user (
    id         INT          NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    username   VARCHAR(50)  NOT NULL COMMENT '用户名',
    password   VARCHAR(255) NOT NULL COMMENT '密码（bcrypt加密）',
    nickname   VARCHAR(50)           COMMENT '昵称',
    avatar     VARCHAR(255)          COMMENT '头像URL' DEFAULT 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg',
    gender     ENUM('male','female','unknown') COMMENT '性别' DEFAULT 'unknown',
    bio        VARCHAR(500)          COMMENT '个人简介' DEFAULT '这个人很懒，什么都没留下',
    phone      VARCHAR(20)           COMMENT '手机号',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

-- ============================================================
-- 4. 用户令牌表
-- ============================================================
CREATE TABLE IF NOT EXISTS user_token (
    id         INT          NOT NULL AUTO_INCREMENT COMMENT '令牌ID',
    user_id    INT          NOT NULL COMMENT '用户ID',
    token      VARCHAR(255) NOT NULL COMMENT '令牌值',
    expires_at DATETIME     NOT NULL COMMENT '过期时间',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_token (token),
    INDEX idx_user_id (user_id),
    CONSTRAINT fk_token_user FOREIGN KEY (user_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户令牌表';

-- ============================================================
-- 5. 收藏表
-- ============================================================
CREATE TABLE IF NOT EXISTS favorite (
    id         INT      NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    user_id    INT      NOT NULL COMMENT '用户ID',
    news_id    INT      NOT NULL COMMENT '新闻ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_news (user_id, news_id),
    INDEX idx_user (user_id),
    INDEX idx_news (news_id),
    CONSTRAINT fk_fav_user FOREIGN KEY (user_id) REFERENCES user(id),
    CONSTRAINT fk_fav_news FOREIGN KEY (news_id) REFERENCES news(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';

-- ============================================================
-- 6. 浏览历史表
-- ============================================================
CREATE TABLE IF NOT EXISTS history (
    id        INT      NOT NULL AUTO_INCREMENT COMMENT '历史ID',
    user_id   INT      NOT NULL COMMENT '用户ID',
    news_id   INT      NOT NULL COMMENT '新闻ID',
    view_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
    PRIMARY KEY (id),
    INDEX idx_user (user_id),
    INDEX idx_news (news_id),
    INDEX idx_view_time (view_time),
    CONSTRAINT fk_hist_user FOREIGN KEY (user_id) REFERENCES user(id),
    CONSTRAINT fk_hist_news FOREIGN KEY (news_id) REFERENCES news(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='浏览历史表';

-- ============================================================
-- 7. AI 对话会话表
-- ============================================================
CREATE TABLE IF NOT EXISTS user_chat_session (
    id                  INT          NOT NULL AUTO_INCREMENT COMMENT '会话主键ID',
    user_id             INT          NOT NULL COMMENT '用户ID',
    session_id          VARCHAR(36)  NOT NULL COMMENT '会话UUID',
    title               VARCHAR(255)          COMMENT '会话标题',
    summary             VARCHAR(500)          COMMENT '会话摘要',
    last_summary_index  INT          NOT NULL DEFAULT 0 COMMENT '摘要更新时的消息索引',
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_session_id (session_id),
    INDEX idx_user_id (user_id),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI对话会话表';

-- ============================================================
-- 8. AI 对话消息表
-- ============================================================
CREATE TABLE IF NOT EXISTS chat_message (
    id            INT          NOT NULL AUTO_INCREMENT COMMENT '消息主键ID',
    user_id       INT          NOT NULL COMMENT '用户ID',
    session_id    VARCHAR(36)  NOT NULL COMMENT '会话UUID',
    role          VARCHAR(20)  NOT NULL COMMENT '角色：user/assistant/system/tool',
    content       TEXT         NOT NULL COMMENT '消息内容',
    message_index INT          NOT NULL DEFAULT 0 COMMENT '会话内消息顺序',
    model_name    VARCHAR(100)          COMMENT '模型名称',
    finish_reason VARCHAR(50)           COMMENT '结束原因',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    INDEX idx_user_id (user_id),
    INDEX idx_session_id (session_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI对话消息表';

-- ============================================================
-- 插入示例数据
-- ============================================================

-- 新闻分类
INSERT INTO news_category (id, name, sort_order) VALUES
(1, '科技', 1),
(2, '财经', 2),
(3, '体育', 3),
(4, '娱乐', 4),
(5, '国际', 5);

-- 示例新闻（共12条，覆盖5个分类）
INSERT INTO news (title, description, content, image, author, category_id, views, publish_time) VALUES
-- 科技（3条）
('国产大模型迎来新突破：多模态能力对标 GPT-4o',
 '国内多家科技企业发布最新大模型，在图文理解、代码生成和逻辑推理等维度取得显著进展。',
 '近日，国内人工智能领域迎来密集发布期。多家科技企业相继推出新一代大语言模型，在多模态理解、长上下文处理和代码生成等核心能力上实现了显著提升。\n\n据悉，新一代模型普遍支持超过 128K 的上下文窗口，部分模型甚至达到了百万级 token 的处理能力。在多模态方面，新模型不仅能理解图片内容，还能处理视频和音频输入，实现了真正的全模态交互。\n\n业内专家表示，国产大模型在中文理解、本土化场景适配方面具有天然优势，随着技术不断成熟，有望在教育、医疗、金融等垂直领域实现大规模落地应用。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '科技日报', 1, 1250, NOW() - INTERVAL 0 HOUR),

('量子计算机再获里程碑进展：千量子比特处理器问世',
 '研究团队成功研制出拥有 1000+ 量子比特的超导处理器，纠错能力大幅提升。',
 '国际顶尖研究团队宣布成功研制出拥有超过 1000 个量子比特的超导量子处理器，标志着量子计算硬件迈入新阶段。\n\n该处理器采用了全新的可调耦合器架构，显著降低了串扰噪声，同时引入了表面码纠错方案，将逻辑错误率降低了两个数量级。研究团队表示，这是实现容错量子计算的关键一步。\n\n尽管距离实用化仍有距离，但这一突破为未来在密码破解、药物分子模拟、组合优化等领域的应用奠定了硬件基础。业界预计，5 年内有望出现首个量子优势应用场景。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '前沿科学', 1, 1050, NOW() - INTERVAL 6 HOUR),

('开源生态系统蓬勃发展：国产操作系统装机量突破新纪录',
 '多款国产开源操作系统在桌面和服务器市场取得亮眼成绩，生态适配持续完善。',
 '近年来，国产开源操作系统在桌面端和服务器端市场持续发力，累计装机量突破新纪录。\n\n在桌面端，多款基于 Linux 内核的国产操作系统发布了新版本，在用户体验、软件兼容性和硬件驱动支持方面均有明显改善。WPS、微信、钉钉等常用软件已实现原生适配，日常办公场景基本覆盖。\n\n在服务器端，国产操作系统在云计算、数据库和人工智能基础设施领域得到了广泛应用。多家云厂商宣布将国产操作系统作为默认镜像选项，进一步推动了生态成熟。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '信息技术周刊', 1, 850, NOW() - INTERVAL 12 HOUR),

-- 财经（3条）
('A股市场稳步回升：科技创新板块领涨',
 '受政策利好提振，A股三大指数集体上涨，半导体和人工智能板块表现亮眼。',
 '今日A股市场迎来全面上涨，上证指数、深证成指和创业板指均录得可观涨幅。\n\n从板块来看，科技创新方向领涨大盘。半导体板块受国产替代预期催化，多只个股涨停；人工智能板块在算力需求持续增长的背景下表现强劲。\n\n机构分析认为，当前市场估值处于历史较低区间，政策面持续释放积极信号，中长期配置价值凸显。建议投资者关注科技创新、高端制造和消费复苏三条主线。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '财经早报', 2, 1150, NOW() - INTERVAL 18 HOUR),

('数字人民币试点扩围：跨境支付场景取得新进展',
 '数字人民币在多个城市扩大试点，跨境结算应用场景持续丰富。',
 '中国人民银行近日宣布进一步扩大数字人民币试点范围，新增多个城市纳入试点区域。\n\n在跨境支付方面，数字人民币与多个国家和地区的央行数字货币开展了联合测试，在贸易结算、跨境汇款等场景中验证了技术可行性和效率优势。\n\n专家指出，数字人民币的推广将有效降低跨境支付成本和时间，提升人民币在国际贸易中的使用便利度，助力人民币国际化进程。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '金融观察', 2, 950, NOW() - INTERVAL 24 HOUR),

('新能源汽车出口持续高增长：海外市场版图不断扩大',
 '国产新能源汽车在欧洲、东南亚等市场表现强劲，出口量同比增长超 50%。',
 '据最新海关数据，国产新能源汽车出口继续保持高速增长态势，同比增长超过 50%，海外市场版图不断扩大。\n\n从出口目的地来看，欧洲仍然是最大市场，占比超过四成。东南亚、中东和南美等新兴市场增长迅猛，成为新的增长极。\n\n行业分析指出，国产新能源汽车在电池技术、智能驾驶和成本控制方面具有综合优势，随着海外渠道网络和售后服务体系的完善，出口增长趋势有望延续。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '产业经济报', 2, 750, NOW() - INTERVAL 30 HOUR),

-- 体育（2条）
('中国女排重返世界之巅：时隔多年再夺世界冠军',
 '中国女排在世界锦标赛决赛中逆转夺冠，展现顽强拼搏精神。',
 '在刚刚结束的世界女排锦标赛决赛中，中国女排在先失一局的不利局面下连扳三局，以 3:1 逆转对手，时隔多年再次捧起世界冠军奖杯。\n\n本场比赛中，队长发挥出色，全场贡献 25 分，成为球队获胜的关键人物。年轻主攻手也在关键时刻展现了大心脏，多次在关键分上完成扣杀。\n\n主教练在赛后采访中表示，这座冠军奖杯属于全体队员和教练组，是长期刻苦训练和永不放弃精神的最好回报。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '体育头条', 3, 650, NOW() - INTERVAL 36 HOUR),

('马拉松赛事火热：全国百城联动点燃全民健身热情',
 '全国百余座城市同步举办马拉松赛事，参与人数创历史新高。',
 '本周末，全国百余座城市同步举办马拉松赛事，吸引了数十万名跑步爱好者参与，参赛人数创历史新高。\n\n赛事设置了全程马拉松、半程马拉松和欢乐跑等多个组别，满足不同水平跑者的需求。多个城市的赛道沿途设置了特色补给站和文化展示区，将体育赛事与城市文旅深度融合。\n\n近年来，马拉松运动在国内持续升温，已成为推动全民健身的重要抓手。赛事的火热也带动了运动装备、体育旅游等相关产业的发展。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '全民健身', 3, 550, NOW() - INTERVAL 42 HOUR),

-- 娱乐（2条）
('国产科幻大片全球热映：海外票房创华语电影新纪录',
 '一部国产科幻电影在全球多地同步上映，海外票房打破华语电影历史纪录。',
 '一部备受瞩目的国产科幻大片在全球多地同步上映，上映首周便引发观影热潮，海外票房打破华语电影历史纪录。\n\n该片以宏大的宇宙视野和精湛的视觉特效著称，讲述了一个关于人类文明延续的史诗故事。影片在北美、欧洲和东南亚等主要电影市场均取得了亮眼成绩。\n\n影评人普遍认为，这部影片标志着中国电影工业水准迈上新台阶，在特效制作、叙事节奏和情感表达方面均达到了国际一流水平。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '娱乐前线', 4, 450, NOW() - INTERVAL 48 HOUR),

('音乐节经济持续升温：拉动文旅消费新引擎',
 '各地音乐节密集开演，带动周边餐饮、住宿和交通消费大幅增长。',
 '随着演出市场全面复苏，各地音乐节密集开演，已成为拉动文旅消费的新引擎。\n\n据统计，一场大型音乐节通常能吸引数万名观众，其中跨城观演比例超过 60%。音乐节带动了举办地周边的餐饮、住宿、交通和零售消费大幅增长，综合经济拉动效应显著。\n\n业内人士指出，音乐节经济的火热反映了年轻消费群体对文化体验消费的旺盛需求，未来在内容品质和运营规范化方面仍有提升空间。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '文化周刊', 4, 350, NOW() - INTERVAL 54 HOUR),

-- 国际（2条）
('全球气候大会达成新共识：各国承诺加速清洁能源转型',
 '联合国气候大会闭幕，与会各国就加速清洁能源转型达成多项共识。',
 '联合国气候变化大会在经过两周的密集磋商后闭幕，与会各国就加速清洁能源转型达成多项重要共识。\n\n大会最终文件呼吁各国在 2030 年前将全球可再生能源装机容量再增加两倍，能源效率提升一倍。同时，发达国家承诺向发展中国家提供更多气候资金支持，帮助其应对气候变化和推进绿色转型。\n\n尽管在化石燃料退出时间表等问题上仍存在分歧，但与会各方普遍认为本次大会取得了实质性进展，为全球气候治理注入了新动力。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '国际观察', 5, 250, NOW() - INTERVAL 60 HOUR),

('国际贸易新格局：多边合作机制取得积极进展',
 '多个区域性贸易协定谈判取得突破，多边合作机制展现新活力。',
 '近期，多个区域性贸易协定谈判取得突破性进展，多边合作机制展现新活力。\n\n在亚太地区，区域全面经济伙伴关系协定（RCEP）持续深化，成员国间贸易便利化水平不断提升，关税减让红利逐步释放。\n\n同时，多个新的双边和区域贸易协定谈判也在积极推进中，涵盖数字贸易、绿色经济和供应链合作等新兴领域。分析人士认为，多边贸易体系的完善将为全球经济复苏提供有力支撑。',
 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg', '环球财经', 5, 150, NOW() - INTERVAL 66 HOUR);

-- 测试用户（密码: 123456，bcrypt 哈希）
INSERT INTO user (username, password, nickname, gender, bio) VALUES
('admin', '$2b$12$ubBt4p0yDMM74aO4Ua5R..s3IKEaDz0/ZaUcDfvWI2VLLYcOJiHGG', '管理员', 'unknown', '测试账号，密码: 123456');
