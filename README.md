概要
====

任天堂スイッチを販売しているサイトをクロールし、在庫があるかチェックするスクリプトです。在庫があると標準出力に在庫情報を出力します。

チェックしているサイト
- Amazon
- あみあみ
- エディオン
- HMV
- イトーヨーカドー
- ジョーシン
- ノジマ
- OMNI7
- 楽天ブックス
- トイザらス
- ヤマダ
- ヨドバシ



インストール方法
================

あらかじめ Ruby をインストールする必要があります。  
バージョンは2.3以上が必要です。rvm とか rbenv でインストールしてください。  
あとは bundle install するだけです。

```
$ bundle install
```

使い方
======

```
$ ./check-switch-shop
販売中！急げ！

- Amazon
https://www.amazon.co.jp/b//ref=as_li_ss_tl?ie=UTF8&node=4731379051&linkCode=ll2&tag=vrinfo-22&linkId=ebf436d903ca774e58ecfd6f0bde9d94
【Amazon.co.jp限定】【液晶保護フィルムEX付き (任天堂ライセンス商品) 】Nintendo Switch Joy-Con (L) ネオンブルー/ (R) ネオンレッド+マイクロファイバークロス
￥ 33,329

【Amazon.co.jp限定】【液晶保護フィルムEX付き(任天堂ライセンス商品)】Nintendo Switch Joy-Con(L) ネオンブルー/(R) ネオンレッド
￥ 32,378
```

在庫がある場合、このような出力になります。  
また在庫がある場合、コマンドの終了コードが 0 で、ない場合は 1 です。  



Slack を使う場合の例
--------------------
Slack などと組み合わせるとかなり強力です。Slack はスマホへの通知までするので見逃すことはほぼありません。  
Slack で incoming hook を作成し、そのURLに対して curl でポストするだけのスクリプトを作ります。  
例えば post-slack というファイルを作り、以下のように編集します。  

```post-slack
if [ -p /dev/stdin ]; then
  cat -
else
  echo $@
fi | curl -s -X POST --data-urlencode "payload={\"text\": \"$(cat -)\"}" $SLACK_INCOMINGHOOK_URL
```

$SLACK_INCOMINGHOOK_URL を incoming hook で登録して URL に変更します。  
これを cron と組み合わせて以下のように登録します。  

```
* * * * * /bin/bash -l -c "cd $PATH_TO_INSTALL/check-switch-shop && ./check-switch-shop.rb > output.log && (cat output.log | ./post-slack)"
```



## License
MIT
