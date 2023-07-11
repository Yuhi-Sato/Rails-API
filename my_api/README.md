# Rails API Tutorial

参考文献

https://guides.rubyonrails.org/api_app.html#choosing-middleware

[https://railsguides.jp/api_app.html](https://railsguides.jp/getting_started.html)

[https://github.com/cookpad/cookpad-internship-2022-summer-serverside](https://github.com/cookpad/cookpad-internship-2023-summer-server-public)

# 手順

### 環境構築

---

- rubyのバージョン確認

`ruby -v`

- railsのインストール

`sudo gem install rails`

- バージョン確認

`rails --version`

cloud9はここからスタート

- my_apiプロジェクトを作成

`rails new my_api --api`

- ディレクトリを移動

`cd my_api`

  
### レスポンス{"Hello":"Rails"}を得る

---

APIを叩いて、{"Hello":"Rails"}と出力させたいと思います。

始めに、ルーティング設定を行います。`/articles`エンドポイントにGETメソッドでリクエストを行うと、articlesコントローラーのindexメソッドを実行するよう設定

/my_api/config/routes.rb

```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/articles", to: "articles#index"
end
```

- articlesコントローラーを作成

`touch app/controllers/articles_controller.rb`

/my_api/app/controllers/articles_controller.rb

```ruby
class ArticlesController < ApplicationController
  def index
      render json: { "Hello": "Rails" }
  end
end
```

- Railsサーバーをポート8080で起動させる

`rails s -p 8080`

- 別ターミナルを開き、APIを叩く

`curl 'http://localhost:8080/articles'`

実行結果　　
`{ "Hello": "Rails" }`

  
### Articleモデル作成

---

Articlesモデルを作成します

- ディレクトリを移動

`cd my_api`

- モデル作成

`bundle exec rails g model article --no-migration --skip-test-framework`

次に、Articlesテーブルを作成したいと思います。

/my_api/Gemfileに以下を追記します

```ruby
gem 'ridgepole'
```

rigepoleでは、テーブルの定義をSchemafileに記述すると実際のDBとの差分を検知してくれます。

- Gemfileのパッケージをインストール

`bundle install`

- Schemaファイルを作成

`touch db/Schemafile`  
my_api/db/Schemafile
```ruby
create_table :articles do |t|
    t.string :title
    t.text :body
    
    t.timestamps
end
```

- テーブルを作成

`bundle exec ridgepole --apply --file db/Schemafile --config config/database.yml`

次に、ダミーデータを作成してみます。

- railsコンソール画面を開く

`rails console`

- articleダミーデータ作成

```bash
yuhi.link:~/environment/my_api (master) $ rails console
Running via Spring preloader in process 25293
Loading development environment (Rails 6.1.7.4)
   (1.2ms)  SELECT sqlite_version(*)
  TRANSACTION (0.9ms)  begin transaction
  Article Create (3.8ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "長尾研Wiki"], ["body", "長尾先生はNEDOが嫌い"], ["created_at", "2023-07-05 08:09:35.206328"], ["updated_at", "2023-07-05 08:09:35.206328"]]
  TRANSACTION (4.7ms)  commit transaction
 => 
#<Article:0x0000000003789620
... 
 => 
#<Article:0x0000000003789620
 id: 1,
 title: "長尾研Wiki",
 body: "長尾研の進化計算は日本一ぃぃぃぃぃぃ",
 created_at: Wed, 05 Jul 2023 08:09:35.206328606 UTC +00:00,
 updated_at: Wed, 05 Jul 2023 08:09:35.206328606 UTC +00:00>
```

  
### レスポンスを整形する

---

articleテーブルの全データをレスポンスとして返したいと思います。

- articlesコントローラーを整形する

/my_api/app/controllers/articles_controller.rb

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.first(10)
    render json: @articles
  end
end
```

- APIを叩く

`curl 'http://localhost:8080/articles'`

実行結果

```bash
~/environment/my_api (master) $ curl 'http://localhost:8080/articles'
[{"id":1,"title":"長尾研Wiki","body":"長尾研の進化計算は日本一ぃぃぃぃぃぃ","created_at":"2023-07-05T08:09:35.206Z","updated_at":"2023-07-05T08:09:35.206Z"}]
```

作成日や更新日はレスポンスとして要らないので、省きたいと思います。そこで、[ActiveModelSerializers](https://github.com/rails-api/active_model_serializers/tree/0-10-stable)というパッケージを利用します。

/my_api/Gemfileに以下を追記します

```bash
gem 'active_model_serializers'
```

忘れずに

`bundle install`

articleのシリアライザーを作成

`mkdir touch app/serializers`

`touch app/serializers/article_serializer.rb`

/my_api/app/serializers/article_serializer.rb

```ruby
class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
end
```

実行結果

```ruby
yuhi.link:~/environment/my_api (master) $ curl 'http://localhost:8080/articles'
[{"id":1,"title":"長尾研Wiki","body":"長尾研の進化計算は日本一ぃぃぃぃぃぃ"}]
```

  
### シードデータ

---

毎度、railsコンソール画面を開いてダミーデータを作るのは面倒なのでシードデータを作成します。

一度、

/my_api/db/seeds.rb

```ruby
Article.create!(
    [
        {
            title: '長尾研Wiki',
            body: '長尾研の進化計算は日本一ぃぃぃぃぃぃ',
        },
        {
            title: '推しの子',
            body: '重曹を舐める天才子役',

        },
        {
            title: '呪術廻戦',
            body: '失礼だな、純愛だよ',
        },
        {
            title: 'ジョジョ スターダストクルセイダーズ',
            body: 'テメェは俺を怒らせた',
        }
    ]
)
```

- テーブルの中身を削除して、DBにシードデータを挿入する

`bundle exec rails db:seed:replant`

- APIを叩く

`curl 'http://localhost:8080/articles'`

実行結果

```bash
[{"id":1,"title":"長尾研Wiki","body":"長尾研の進化計算は日本一ぃぃぃぃぃぃ"},{"id":2,"title":"推しの子","body":"重曹を舐める天才子役"},{"id":3,"title":"呪術廻戦","body":"失礼だな、純愛だよ"},{"id":4,"title":"ジョジョ スターダストクルセイダーズ","body":"テメェは俺を怒らせた"}]
```

  
### POSTメソッド

---

今までは、GETメソッドでデータを参照することだけしてきましたが、今度はPOSTメソッドでDBへデータを登録してみましょう。

- ルーテイングを設定

/my_api/config/routes.rb

```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/articles", to: "articles#index"
  post "/articles", to: "articles#create"
end
```

次にcreateメソッドを作成しますが、その際にストロングパラメータなるものを使用します。詳しくはこちらhttps://qiita.com/ozackiee/items/f100fd51f4839b3fdca8

- コントローラーにcreateメソッドを追加

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.first(10)
    render json: @articles
  end

  def create
    @article = Article.create(article_params)
    render json: @article
  end

  private
  def article_params
    params.require(:article).permit(:title,:body)
  end
end
```

- APIを叩く

`curl -X POST -H "Content-Type: application/json" -d '{"title": "DIO", "body": "そこ に痺れる憧れる"}' 'http://localhost:8080/articles'`

実行結果
```bash
{"id":5,"title":"DIO","body":"そこに痺れる憧れる"}
```
  
  
### idを指定してデータを取得
---
ここからは少し雑にしていきます。不足している部分は各自考えてください。

```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
  post "/articles", to: "articles#create"
end
```

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.first(10)
    render json: @articles
  end

  def show
    @article = Article.find(params[:id])
    render json: @article
  end

  def create
    @article = Article.create(article_params)
    render json: @article
  end

  private
  def article_params
    params.require(:article).permit(:title,:body)
  end
end
```

`curl 'http://localhost:8080/articles/1'`

```Bash
{"id":1,"title":"長尾研Wiki","body":"長尾研の進化計算は日本一ぃぃぃぃぃぃ"}%
```

### idを指定してデータを削除
```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
  post "/articles", to: "articles#create"
  delete "/articles/:id", to: "articles#destroy"
end
```

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.first(10)
    render json: @articles
  end

  def show
    @article = Article.find(params[:id])
    render json: @article
  end

  def create
    @article = Article.create(article_params)
    render json: @article
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
  end

  private
  def article_params
    params.require(:article).permit(:title,:body)
  end
end
```

`curl -X DELETE -H "Content-Type: application/json" 'http://localhost:8080/articles/1'`

### userテーブルを作成
---
`bundle exec rails g model user --no-migration --skip-test-framework`

my_api/db/Schemafile
```ruby
create_table :articles do |t|
    t.string :title
    t.text :body
    
    t.timestamps
end

create_table :users do |t|
    t.string :name, null: false
    t.timestamps
end
```

```ruby
class Article < ApplicationRecord
    belongs_to :user
end
```

```ruby
class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  belongs_to :user
end
```

```ruby
class UserSerializer < ActiveModel::Serializer
    attributes :id, :name
end
```

```ruby
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
```

`bundle exec ridgepole --apply --file db/Schemafile --config config/database.yml`  
`bundle exec rails db:seed:replant`  
`curl 'http://localhost:8080/articles'`  
