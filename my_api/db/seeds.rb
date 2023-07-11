User.create!(
    [
        { name: 'Sato' },
        { name: 'Suzuki' },
        { name: 'Takahashi' }
    ]
)

Article.create!(
    [
        {
            user_id: 1,
            title: '長尾研Wiki',
            body: '長尾研の進化計算は日本一ぃぃぃぃぃぃ'
        },
        {
            user_id: 2,
            title: '推しの子',
            body: '重曹を舐める天才子役'
        },
        {
            user_id: 2,
            title: '呪術廻戦',
            body: '失礼だな、純愛だよ'
        },
        {
            user_id: 3,
            title: 'ジョジョ スターダストクルセイダーズ',
            body: 'テメェは俺を怒らせた'
        }
    ]
)