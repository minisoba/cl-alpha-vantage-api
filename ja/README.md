[English](../README.md) | [日本語](./README.md)

# Alpha Vantage API for Common Lisp

[Alpha Vantage API](https://www.alphavantage.co/documentation) の Common Lisp ラッパーライブラリです。
Alpha Vantage が提供する幅広い金融データや時系列データに包括的にアクセスできます。

本ライブラリは、エンドポイント URL 生成レイヤーと、JSON レスポンスを CLOS オブジェクトにパースするデータ取得レイヤーで構成されています。

現在、以下のエンドポイントには対応していません：

- NEWS_SENTIMENT
- TOP_GAINERS_LOSERS
- LISTING_STATUS（URL 生成のみ）
- EARNINGS_CALENDAR（URL 生成のみ）
- IPO_CALENDAR（URL 生成のみ）


## インストール

ASDF に対応しており、以下のコマンドでロードできます：
```common-lisp
(asdf:load-system "cl-alpha-vantage-api")
```

### 依存ライブラリ

- alexandria
- cl-change-case
- cl-ppcre
- closer-mop
- drakma
- duckdb
- local-time
- parse-float
- yason
- fiveam（ユニットテスト）

動作確認済みの処理系：

- SBCL (2.3.1)
- LispWorks (7.1.2)


## クイックスタート

```common-lisp
;; API トークンを設定
(alpha-vantage:set-api-token "YOUR-API-TOKEN")

;; AAPL の日次 OHLC 時系列データを取得
(alpha-vantage:get-time-series
 (alpha-vantage:time-series-daily :symbol "AAPL"))

;; 時系列データをイテレーション
(alpha-vantage:do-time-series (ts (alpha-vantage:time-series-daily :symbol "AAPL") 'alpha-vantage:timestamp-of)
  (format t "~a: ~a~%" (alpha-vantage:timestamp-of ts) (alpha-vantage:close-price-of ts)))

;; 企業概要を取得
(alpha-vantage:get-overview "AAPL")

;; ファンダメンタルデータを取得
(alpha-vantage:get-income-statement-series "AAPL")

;; 時系列データを Parquet ファイルに保存
(alpha-vantage:save-to-parquet
 (alpha-vantage:get-time-series
  (alpha-vantage:time-series-daily :symbol "AAPL"))
 "/tmp/aapl-daily.parquet")
```


## API

各 API 関数は `end-point-schema.lisp` で定義されており、以下のフォーマットに従います。
`defendpoint` マクロがエンドポイントスキーマを解析し、関数を生成します。

```
(関数名
 グループ名)
 . ((引数名 フィールド属性 (:required or :optional) フィールド型)
    (引数名 フィールド属性 (:required or :optional) フィールド型)
    ...)
```

### グローバル変数

##### `*api-token*`

Alpha Vantage API のアクセストークン。`set-api-token` または `setf` で設定します。

##### `*end-point-table*`

API エンドポイント構造体のルーティングテーブル。各エントリは `:name` と `:group` を持ちます。

##### `*http-headers*`

直近の API リクエストの HTTP レスポンスヘッダー。

##### `*http-status-code*`

直近の API リクエストの HTTP ステータスコード。

##### `*http-reason-phrase*`

直近の API リクエストの HTTP 理由フレーズ。

##### `+query-url-base+`

Alpha Vantage API のベース URL。


### クラス

#### 時系列クラス

##### `time-series`

コモディティ・経済指標向け時系列クラス。スロット：`value-of`、`timestamp-of`。

##### `time-series-ohcl`

株式向け OHLC 時系列クラス。スロット：`open-price-of`、`high-price-of`、`low-price-of`、`close-price-of`、`volume-of`、`timestamp-of`。

##### `fx-time-series-ohcl`

外国為替向け OHLC 時系列クラス。スロット：`open-price-of`、`high-price-of`、`low-price-of`、`close-price-of`、`timestamp-of`。

##### `crypto-time-series-ohcl`

暗号資産向け OHLC 時系列クラス。スロット：`open-price-of`、`open-price-usd-of`、`high-price-of`、`high-price-usd-of`、`low-price-of`、`low-price-usd-of`、`close-price-of`、`close-price-usd-of`、`volume-of`、`market-cap-usd-of`、`timestamp-of`。

##### `ta-time-series`

テクニカル指標時系列クラス。スロット：`ta-values-of`（指標キー/値ペアの連想リスト）、`timestamp-of`。

##### `quote-snapshot`

Global Quote エンドポイントの気配値スナップショットクラス。スロット：`ticker-of`、`open-price-of`、`high-price-of`、`low-price-of`、`price-of`、`volume-of`、`timestamp-of`、`previous-close-price-of`、`change-of`、`change-percent-of`。

##### `fx-quote-snapshot`

Currency Exchange Rate エンドポイントの為替スナップショットクラス。スロット：`from-ccy-code-of`、`from-ccy-name-of`、`to-ccy-code-of`、`to-ccy-name-of`、`exchange-rate-of`、`timezone-of`、`timestamp-of`、`bid-price-of`、`ask-price-of`。

#### ファンダメンタルクラス

##### `overview`

企業概要と財務指標：`ticker-of`、`name-of`、`description-of`、`sector-of`、`industry-of`、`market-capitalization-of`、`pe-ratio-of`、`eps-of`、`dividend-yield-of`、`beta-of`、`52-week-high-of`、`52-week-low-of` 他多数。

##### `income-statement`

損益計算書。スロット：`report-period-of`、`fiscal-date-ending-of`、`reported-currency-of`、`gross-profit-of`、`total-revenue-of`、`operating-income-of`、`net-income-of`、`ebitda-of` 等。

##### `balance-sheet`

貸借対照表。スロット：`report-period-of`、`fiscal-date-ending-of`、`reported-currency-of`、`total-assets-of`、`total-liabilities-of`、`total-shareholder-equity-of` 等。

##### `cash-flow`

キャッシュフロー計算書。スロット：`report-period-of`、`fiscal-date-ending-of`、`reported-currency-of`、`operating-cashflow-of`、`capital-expenditures-of`、`cashflow-from-investment-of`、`cashflow-from-financing-of`、`net-income-of` 等。

##### `earnings`

収益データ。スロット：`report-period-of`、`fiscal-date-ending-of`、`reported-eps-of`。

#### 銘柄検索クラス

##### `symbol-search`

スロット：`ticker-of`、`name-of`、`instrument-type-of`、`region-of`、`market-open-of`、`market-close-of`、`timezone-of`、`ccy-of`、`match-score-of`。


### データ取得関数

すべてのデータ取得関数は `api.lisp` に定義されています。

##### `get-time-series`

```common-lisp
(get-time-series query &optional (date-time-column 'timestamp-of))
```

Alpha Vantage の QUERY URL からデータを取得し、DATE-TIME-COLUMN でソートされた時系列を返します。

```common-lisp
CL-USER> (alpha-vantage:get-time-series
           (alpha-vantage:time-series-daily :symbol "AAPL"))
;; => timestamp でソートされた TIME-SERIES-OHCL オブジェクトのリスト
```

##### [マクロ] `do-time-series`

```common-lisp
(do-time-series (var query date-time-column) &body body)
```

時系列の各要素を VAR に束縛してイテレーションします。

```common-lisp
CL-USER> (alpha-vantage:do-time-series
           (ts (alpha-vantage:sma :symbol "AAPL" :interval :daily
                                  :time-period 20 :series-type :close)
               'alpha-vantage:timestamp-of)
           (format t "~a~%" (alpha-vantage:ta-values-of ts)))
```

##### `get-overview`

```common-lisp
(get-overview symbol)
```

SYMBOL の OVERVIEW オブジェクトを返します。

```common-lisp
CL-USER> (alpha-vantage:get-overview "AAPL")
;; => OVERVIEW インスタンス
```

##### `get-income-statement-series`

```common-lisp
(get-income-statement-series symbol)
```

SYMBOL の INCOME-STATEMENT オブジェクトの時系列を返します。

```common-lisp
CL-USER> (alpha-vantage:get-income-statement-series "AAPL")
;; => fiscal-date-ending でソートされた INCOME-STATEMENT オブジェクトのリスト
```

##### `get-balance-sheet-series`

```common-lisp
(get-balance-sheet-series symbol)
```

SYMBOL の BALANCE-SHEET オブジェクトの時系列を返します。

```common-lisp
CL-USER> (alpha-vantage:get-balance-sheet-series "AAPL")
;; => fiscal-date-ending でソートされた BALANCE-SHEET オブジェクトのリスト
```

##### `get-cash-flow-series`

```common-lisp
(get-cash-flow-series symbol)
```

SYMBOL の CASH-FLOW オブジェクトの時系列を返します。

```common-lisp
CL-USER> (alpha-vantage:get-cash-flow-series "AAPL")
;; => fiscal-date-ending でソートされた CASH-FLOW オブジェクトのリスト
```

##### `get-earnings-series`

```common-lisp
(get-earnings-series symbol)
```

SYMBOL の EARNINGS オブジェクトの時系列を返します。

```common-lisp
CL-USER> (alpha-vantage:get-earnings-series "AAPL")
;; => fiscal-date-ending でソートされた EARNINGS オブジェクトのリスト
```


### Parquet エクスポート

##### `save-to-parquet`

```common-lisp
(save-to-parquet objects parquet-path &key (table-name "alpha_vantage_data"))
```

CLOS オブジェクトのリストを DuckDB 経由で Parquet ファイルに書き出します。各オブジェクトのダイレクトスロットがカラムにマッピングされます。リスト内のすべてのオブジェクトは同じ型・スロット構成である必要があります。

スロットの initform によりカラム型が決定されます：`0` → BIGINT、`0.0` → DOUBLE、その他 → VARCHAR。

```common-lisp
;; 日次 OHLC データを保存
CL-USER> (alpha-vantage:save-to-parquet
          (alpha-vantage:get-time-series
           (alpha-vantage:time-series-daily :symbol "AAPL"))
          "/tmp/aapl-daily.parquet")

;; カスタムテーブル名で損益計算書を保存
CL-USER> (alpha-vantage:save-to-parquet
          (alpha-vantage:get-income-statement-series "AAPL")
          "/tmp/aapl-income.parquet"
          :table-name "income_statements")
```


### エンドポイント URL 関数

各関数は Alpha Vantage API のクエリ URL を生成します。命名規則は Alpha Vantage の関数名を Lisp スタイル（アンダースコアをハイフンに変換）に従います。すべてのエンドポイント関数は `end-points.lisp` で定義されています。


#### 株式 API

##### `time-series-intraday`

```common-lisp
(time-series-intraday &key symbol interval adjusted outputsize)
;; symbol     - ティッカーシンボル（文字列、必須）
;; interval   - :1min :5min :15min :30min :60min（必須）
;; adjusted   - :true :false（任意）
;; outputsize - :compact :full（任意）
```

```common-lisp
CL-USER> (alpha-vantage:time-series-intraday :symbol "AAPL" :interval :5min)
"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&apikey=...&symbol=AAPL&interval=5min"
```

[リファレンス](https://www.alphavantage.co/documentation/#intraday)

##### `time-series-daily`

```common-lisp
(time-series-daily &key symbol outputsize)
;; symbol     - ティッカーシンボル（文字列、必須）
;; outputsize - :compact :full（任意）
```

```common-lisp
CL-USER> (alpha-vantage:time-series-daily :symbol "AAPL")
"https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&apikey=...&symbol=AAPL"
```

##### `time-series-daily-adjusted`

```common-lisp
(time-series-daily-adjusted &key symbol outputsize)
;; symbol     - ティッカーシンボル（文字列、必須）
;; outputsize - :compact :full（任意）
```

##### `time-series-weekly`

```common-lisp
(time-series-weekly &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

##### `time-series-weekly-adjusted`

```common-lisp
(time-series-weekly-adjusted &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

##### `time-series-monthly`

```common-lisp
(time-series-monthly &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

##### `time-series-monthly-adjusted`

```common-lisp
(time-series-monthly-adjusted &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

##### `global-quote`

```common-lisp
(global-quote &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

```common-lisp
CL-USER> (alpha-vantage:global-quote :symbol "AAPL")
"https://www.alphavantage.co/query?function=GLOBAL_QUOTE&apikey=...&symbol=AAPL"
```

##### `symbol-search`

```common-lisp
(symbol-search &key keywords)
;; keywords - 検索キーワード（文字列、必須）
```

```common-lisp
CL-USER> (alpha-vantage:symbol-search :keywords "microsoft")
"https://www.alphavantage.co/query?function=SYMBOL_SEARCH&apikey=...&keywords=microsoft"
```

##### `market-status`

```common-lisp
(market-status)
```


#### ファンダメンタルデータ

##### `overview`

```common-lisp
(overview &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

```common-lisp
CL-USER> (alpha-vantage:overview :symbol "AAPL")
"https://www.alphavantage.co/query?function=OVERVIEW&apikey=...&symbol=AAPL"
```

##### `income-statement`

```common-lisp
(income-statement &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

##### `balance-sheet`

```common-lisp
(balance-sheet &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

##### `cash-flow`

```common-lisp
(cash-flow &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```

##### `earnings`

```common-lisp
(earnings &key symbol)
;; symbol - ティッカーシンボル（文字列、必須）
```


#### 外国為替（FX）

##### `currency-exchange-rate`

```common-lisp
(currency-exchange-rate &key from-currency to-currency)
;; from-currency - ISO 通貨コード（文字列、3文字、必須）
;; to-currency   - ISO 通貨コード（文字列、3文字、必須）
```

```common-lisp
CL-USER> (alpha-vantage:currency-exchange-rate :from-currency "USD" :to-currency "JPY")
"https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&apikey=...&from_currency=USD&to_currency=JPY"
```

##### `fx-intraday`

```common-lisp
(fx-intraday &key from-symbol to-symbol interval outputsize)
;; from-symbol - ISO 通貨コード（文字列、3文字、必須）
;; to-symbol   - ISO 通貨コード（文字列、3文字、必須）
;; interval    - :1min :5min :15min :30min :60min（必須）
;; outputsize  - :compact :full（任意）
```

##### `fx-daily`

```common-lisp
(fx-daily &key from-symbol to-symbol outputsize)
;; from-symbol - ISO 通貨コード（文字列、3文字、必須）
;; to-symbol   - ISO 通貨コード（文字列、3文字、必須）
;; outputsize  - :compact :full（任意）
```

##### `fx-weekly`

```common-lisp
(fx-weekly &key from-symbol to-symbol)
;; from-symbol - ISO 通貨コード（文字列、3文字、必須）
;; to-symbol   - ISO 通貨コード（文字列、3文字、必須）
```

##### `fx-monthly`

```common-lisp
(fx-monthly &key from-symbol to-symbol)
;; from-symbol - ISO 通貨コード（文字列、3文字、必須）
;; to-symbol   - ISO 通貨コード（文字列、3文字、必須）
```


#### 暗号資産

##### `crypto-intraday`

```common-lisp
(crypto-intraday &key symbol market interval outputsize)
;; symbol     - 暗号資産シンボル、例 "ETH"（文字列、3文字、必須）
;; market     - 取引市場、例 "USD"（文字列、3文字、必須）
;; interval   - :1min :5min :15min :30min :60min（必須）
;; outputsize - :compact :full（任意）
```

##### `digital-currency-daily`（エイリアス：`crypto-daily`）

```common-lisp
(digital-currency-daily &key symbol market)
;; symbol - 暗号資産シンボル、例 "BTC"（文字列、3文字、必須）
;; market - 取引市場、例 "CNY"（文字列、3文字、必須）
```

##### `digital-currency-weekly`（エイリアス：`crypto-weekly`）

```common-lisp
(digital-currency-weekly &key symbol market)
;; symbol - 暗号資産シンボル（文字列、3文字、必須）
;; market - 取引市場（文字列、3文字、必須）
```

##### `digital-currency-monthly`（エイリアス：`crypto-monthly`）

```common-lisp
(digital-currency-monthly &key symbol market)
;; symbol - 暗号資産シンボル（文字列、3文字、必須）
;; market - 取引市場（文字列、3文字、必須）
```


#### コモディティ

##### `wti`

```common-lisp
(wti &key interval)
;; interval - :daily :weekly :monthly（任意）
```

##### `brent`

```common-lisp
(brent &key interval)
;; interval - :daily :weekly :monthly（任意）
```

##### `natural-gas`

```common-lisp
(natural-gas &key interval)
;; interval - :daily :weekly :monthly（任意）
```

##### `copper`

```common-lisp
(copper &key interval)
;; interval - :monthly :quarterly :annual（任意）
```

##### `aluminum`

```common-lisp
(aluminum &key interval)
;; interval - :monthly :quarterly :annual（任意）
```

##### `wheat`

```common-lisp
(wheat &key interval)
;; interval - :monthly :quarterly :annual（任意）
```

##### `corn`

```common-lisp
(corn &key interval)
;; interval - :monthly :quarterly :annual（任意）
```

##### `cotton`

```common-lisp
(cotton &key interval)
;; interval - :monthly :quarterly :annual（任意）
```

##### `sugar`

```common-lisp
(sugar &key interval)
;; interval - :monthly :quarterly :annual（任意）
```

##### `coffee`

```common-lisp
(coffee &key interval)
;; interval - :monthly :quarterly :annual（任意）
```

##### `all-commodities`

```common-lisp
(all-commodities &key interval)
;; interval - :monthly :quarterly :annual（任意）
```


#### 経済指標

##### `real-gdp`

```common-lisp
(real-gdp &key interval)
;; interval - :quarterly :annual（任意）
```

##### `real-gdp-per-capita`

```common-lisp
(real-gdp-per-capita)
```

##### `treasury-yield`

```common-lisp
(treasury-yield &key interval maturity)
;; interval - :daily :weekly :monthly（任意）
;; maturity - :3month :2year :5year :7year :10year :30year（任意）
```

```common-lisp
CL-USER> (alpha-vantage:treasury-yield :interval :monthly :maturity :10year)
"https://www.alphavantage.co/query?function=TREASURY_YIELD&apikey=...&interval=monthly&maturity=10year"
```

##### `federal-funds-rate`

```common-lisp
(federal-funds-rate &key interval)
;; interval - :daily :weekly :monthly（任意）
```

##### `cpi`

```common-lisp
(cpi &key interval)
;; interval - :monthly :semiannual（任意）
```

##### `inflation`

```common-lisp
(inflation)
```

##### `retail-sales`

```common-lisp
(retail-sales)
```

##### `durables`

```common-lisp
(durables)
```

##### `unemployment`

```common-lisp
(unemployment)
```

##### `nonfarm-payroll`

```common-lisp
(nonfarm-payroll)
```


#### テクニカル指標

すべてのテクニカル指標関数は `:symbol`（必須、文字列）と `:interval`（必須、`:1min :5min :15min :30min :60min :daily :weekly :monthly` のいずれか）を受け取ります。多くの関数は `:time-period`（必須、整数）と `:series-type`（必須、`:close :open :high :low` のいずれか）も受け取ります。

##### `sma`

```common-lisp
(sma &key symbol interval time-period series-type)
```

```common-lisp
CL-USER> (alpha-vantage:sma :symbol "AAPL" :interval :daily :time-period 20 :series-type :close)
"https://www.alphavantage.co/query?function=SMA&apikey=...&symbol=AAPL&interval=daily&time_period=20&series_type=close"
```

##### `ema`

```common-lisp
(ema &key symbol interval time-period series-type)
```

##### `wma`

```common-lisp
(wma &key symbol interval time-period series-type)
```

##### `dema`

```common-lisp
(dema &key symbol interval time-period series-type)
```

##### `tema`

```common-lisp
(tema &key symbol interval time-period series-type)
```

##### `trima`

```common-lisp
(trima &key symbol interval time-period series-type)
```

##### `kama`

```common-lisp
(kama &key symbol interval time-period series-type)
```

##### `mama`

```common-lisp
(mama &key symbol interval time-period series-type fastlimit slowlimit)
;; fastlimit - ファストリミット（浮動小数点、任意）
;; slowlimit - スローリミット（浮動小数点、任意）
```

##### `vwap`

```common-lisp
(vwap &key symbol interval)
;; interval - :1min :5min :15min :30min :60min（必須）
```

##### `t3`

```common-lisp
(t3 &key symbol interval time-period series-type)
```

##### `macd`

```common-lisp
(macd &key symbol interval series-type fastperiod slowperiod signalperiod)
;; fastperiod   -（整数、任意）
;; slowperiod   -（整数、任意）
;; signalperiod -（整数、任意）
```

##### `macdext`

```common-lisp
(macdext &key symbol interval series-type fastperiod slowperiod signalperiod fastmatype slowmatype signalmatype)
;; fastmatype   - 移動平均タイプキーワード（任意）
;; slowmatype   - 移動平均タイプキーワード（任意）
;; signalmatype - 移動平均タイプキーワード（任意）
```

移動平均タイプキーワード：`:sma :ema :wma :dema :tema :trima :t3 :kama :mama`

##### `stoch`

```common-lisp
(stoch &key symbol interval fastkperiod slowkperiod slowdperiod slowkmatype slowdmatype)
```

##### `stochf`

```common-lisp
(stochf &key symbol interval fastkperiod fastdperiod fastdmatype)
```

##### `rsi`

```common-lisp
(rsi &key symbol interval time-period series-type)
```

##### `stochrsi`

```common-lisp
(stochrsi &key symbol interval time-period series-type fastkperiod fastdperiod fastdmatype)
```

##### `willr`

```common-lisp
(willr &key symbol interval time-period)
```

##### `adx`

```common-lisp
(adx &key symbol interval time-period)
```

##### `adxr`

```common-lisp
(adxr &key symbol interval time-period)
```

##### `apo`

```common-lisp
(apo &key symbol interval series-type fastperiod slowperiod matype)
```

##### `ppo`

```common-lisp
(ppo &key symbol interval series-type fastperiod slowperiod matype)
```

##### `mom`

```common-lisp
(mom &key symbol interval time-period series-type)
```

##### `bop`

```common-lisp
(bop &key symbol interval)
```

##### `cci`

```common-lisp
(cci &key symbol interval time-period)
```

##### `cmo`

```common-lisp
(cmo &key symbol interval time-period series-type)
```

##### `roc`

```common-lisp
(roc &key symbol interval time-period series-type)
```

##### `rocr`

```common-lisp
(rocr &key symbol interval time-period series-type)
```

##### `aroon`

```common-lisp
(aroon &key symbol interval time-period)
```

##### `aroonosc`

```common-lisp
(aroonosc &key symbol interval time-period)
```

##### `mfi`

```common-lisp
(mfi &key symbol interval time-period)
```

##### `trix`

```common-lisp
(trix &key symbol interval time-period series-type)
```

##### `ultosc`

```common-lisp
(ultosc &key symbol interval timeperiod1 timeperiod2 timeperiod3)
;; timeperiod1 -（整数、任意）
;; timeperiod2 -（整数、任意）
;; timeperiod3 -（整数、任意）
```

##### `dx`

```common-lisp
(dx &key symbol interval time-period)
```

##### `minus-di`

```common-lisp
(minus-di &key symbol interval time-period)
```

##### `plus-di`

```common-lisp
(plus-di &key symbol interval time-period)
```

##### `minus-dm`

```common-lisp
(minus-dm &key symbol interval time-period)
```

##### `plus-dm`

```common-lisp
(plus-dm &key symbol interval time-period)
```

##### `bbands`

```common-lisp
(bbands &key symbol interval time-period series-type nbdevup nbdevdn matype)
;; nbdevup - 上限バンドの標準偏差乗数（整数、任意）
;; nbdevdn - 下限バンドの標準偏差乗数（整数、任意）
;; matype  - 移動平均タイプキーワード（任意）
```

##### `midpoint`

```common-lisp
(midpoint &key symbol interval time-period series-type)
```

##### `midprice`

```common-lisp
(midprice &key symbol interval time-period)
```

##### `sar`

```common-lisp
(sar &key symbol interval acceleration maximum)
;; acceleration - 加速因子（浮動小数点、任意）
;; maximum      - 最大値（浮動小数点、任意）
```

##### `trange`

```common-lisp
(trange &key symbol interval)
```

##### `atr`

```common-lisp
(atr &key symbol interval time-period)
```

##### `natr`

```common-lisp
(natr &key symbol interval time-period)
```

##### `ad`

```common-lisp
(ad &key symbol interval)
```

##### `adosc`

```common-lisp
(adosc &key symbol interval fastperiod slowperiod)
;; fastperiod -（整数、任意）
;; slowperiod -（整数、任意）
```

##### `obv`

```common-lisp
(obv &key symbol interval)
```

##### `ht-trendline`

```common-lisp
(ht-trendline &key symbol interval series-type)
```

##### `ht-sine`

```common-lisp
(ht-sine &key symbol interval series-type)
```

##### `ht-trendmode`

```common-lisp
(ht-trendmode &key symbol interval series-type)
```

##### `ht-dcperiod`

```common-lisp
(ht-dcperiod &key symbol interval series-type)
```

##### `ht-dcphase`

```common-lisp
(ht-dcphase &key symbol interval series-type)
```

##### `ht-phasor`

```common-lisp
(ht-phasor &key symbol interval series-type)
```


## ユニットテスト

テストスイートは [FiveAM](https://github.com/lispworks/fiveam) を使用し、エンドポイント URL 生成とリクエストテストをカバーしています。

```common-lisp
;; テストのロードと実行
(asdf:test-system :cl-alpha-vantage-api)

;; または直接実行
(ql:quickload :cl-alpha-vantage-api-test)
(fiveam:run! 'alpha-vantage.test:alpha-vantage-tests)
```

## ライセンス

MIT
