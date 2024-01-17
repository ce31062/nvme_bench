import tkinter as tk
import subprocess
import os

class BenchmarkApp:
    def __init__(self, root):
        self.root = root
        self.root.title("NVMe Benchmark tool for Linux")
        self.root.geometry("800x400")

        # フレーム1: データ消去のラジオボタン
        self.erase_frame = tk.LabelFrame(self.root, text="データ消去", foreground="green")
        self.erase_frame.grid(column=1, row=1, padx=10, pady=5, sticky="w")

        self.benchmark_type_var_erase = tk.StringVar()
        self.benchmark_type_var_erase.set("trim")  # 初期は "ガベージコレクションを実行する"

        self.trim_radio = tk.Radiobutton(self.erase_frame, text="ガベージコレクションを実行する", variable=self.benchmark_type_var_erase, value="trim")
        self.trim_radio.grid(column=0, row=0, padx=10, pady=5, sticky="w")

        self.secure_erase_radio = tk.Radiobutton(self.erase_frame, text="セキュアイレースを実行する", variable=self.benchmark_type_var_erase, value="secure_erase")
        self.secure_erase_radio.grid(column=1, row=0, padx=10, pady=5, sticky="w")

        # フレーム2: 測定内容のラジオボタン
        self.measure_frame = tk.LabelFrame(self.root, text="測定内容", foreground="blue")
        self.measure_frame.grid(column=1, row=2, padx=10, pady=5, sticky="w")

        self.benchmark_type_var_measure = tk.StringVar()
        self.benchmark_type_var_measure.set("all")  # 初期は "レイテンシ+スループット測定を実行する"

        self.throughput_radio = tk.Radiobutton(self.measure_frame, text="レイテンシ+スループット測定を実行する", variable=self.benchmark_type_var_measure, value="all")
        self.throughput_radio.grid(column=0, row=0, padx=10, pady=5, sticky="w")

        self.throughput_radio = tk.Radiobutton(self.measure_frame, text="スループット測定を実行する", variable=self.benchmark_type_var_measure, value="throughtput")
        self.throughput_radio.grid(column=1, row=0, padx=10, pady=5, sticky="w")

        self.latency_radio = tk.Radiobutton(self.measure_frame, text="レイテンシ測定を実行する", variable=self.benchmark_type_var_measure, value="latency")
        self.latency_radio.grid(column=2, row=0, padx=10, pady=5, sticky="w")

        # ディスクリストの選択用の変数とドロップダウンリストの作成
        self.disk_list = self.get_nvme_disks()
        self.selected_disk = tk.StringVar()
        self.selected_disk.set(self.disk_list[0]) if self.disk_list else ""
        self.disk_menu = tk.OptionMenu(self.root, self.selected_disk, *self.disk_list)
        self.disk_menu.grid(column=1, row=0, padx=10, pady=5, sticky="w")

        # テキスト表示用のラベル
        self.result_label = tk.Label(text="")
        self.result_label.grid(column=1, row=5, padx=10, pady=5, sticky="w")

        # 「All」ボタンの作成
        self.all_button = tk.Button(self.root, text="All", bg="green2", command=self.execute_pcie_test)
        self.all_button.grid(column=0, row=0, padx=10, pady=5, sticky="w")

    # /dev/nvme* のディスクを取得する
    def get_nvme_disks(self):
        nvme_disks = [disk for disk in os.listdir("/dev") if disk.startswith("nvme")]
        return nvme_disks

    def get_selected_disk(self):
        return self.selected_disk.get()

    def execute_pcie_test(self):
        selected_disk = self.get_selected_disk()

        # データ消去ラジオボタンの状態に応じて処理を行う
        benchmark_type_erase = self.benchmark_type_var_erase.get()
        if benchmark_type_erase != "none":
            if selected_disk:
                subprocess.run(["sudo", "bash", "pcie_test.sh", benchmark_type_erase, selected_disk])
                self.result_label.config(text="")
            else:
                self.result_label.config(text="ディスクを選択してください")
        else:
            self.result_label.config(text="データ消去のベンチマーク項目から選択してください")

        # 測定内容ラジオボタンの状態に応じて処理を行う
        benchmark_type_measure = self.benchmark_type_var_measure.get()
        if benchmark_type_measure != "none":
            if selected_disk:
                subprocess.run(["sudo", "bash", "pcie_test.sh", benchmark_type_measure, selected_disk])
                self.result_label.config(text="")
            else:
                self.result_label.config(text="ディスクを選択してください")
        else:
            self.result_label.config(text="測定内容のベンチマーク項目から選択してください")

        # ボタンのテキストを"Stop"に切り替える
        self.all_button.config(text="Stop")

if __name__ == "__main__":
    root = tk.Tk()
    app = BenchmarkApp(root)
    root.mainloop()
