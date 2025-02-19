## 開発環境の構築

bundle インストール

```
$ sudo bundle install
```

config の用意

```
$ cp config-template.yml config.yml
$ vi config.yml # github api_token を設定する
```

実行

```
$ bundle exec ruby app.rb
```

ブラウザで `http://localhost:4567/` にアクセスする。
