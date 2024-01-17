2023/11/18(Tue)
pcie_test_all.sh

//実行コマンド
#bash pcie_test_all.sh {argument}
※pcie_testフォルダ内で実行すること。
※fio.txtをpcie_testフォルダ内に事前に置くこと。

{argument}は評価内容に応じて以下の引数を設定する。
throughput, t: スループット測定のみ
latency, l: レイテンシ測定のみ
all, a: レイテンシ測定＆スループット測定
help: このhelpを表示

例えば、レイテンシ測定のみ行いたい場合は、sudo bash pcie_test_all.sh latency(もしくはl)

//ログ生成
生成場所：pcie_testフォルダ内

ログ名：{argument}=throughput: pcie_throughput.log
　　		   latency: pcie_latency.log
	           all: pcie_all.log

//スクリプト内実行手順
マウント→セキュアイレース→ディレクトリ移動→ベンチマーク測定

//結果の見方
throughput:表示の通り
latency:各測定におけるclat(usec)のavgが、latency値に該当する。
