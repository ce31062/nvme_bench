import tkinter as tk
import subprocess
import os

class BenchmarkApp:
    def __init__(self, root):
        self.root = root
        self.root.title("NVMe Benchmark tool for Linux")
        self.root.geometry("500x300")

        # 「All」ボタンの作成
        self.all_button = tk.Button(self.root, text="All", bg="green2", command=self.execute_pcie_test_all)
        self.all_button.grid(column=0, row=0, padx=10, pady=5, sticky="w")

        # ディスクリストの選択用の変数とドロップダウンリストの作成
        self.disk_list = self.get_nvme_disks()
        self.selected_disk = tk.StringVar()
        self.selected_disk.set(self.disk_list[0]) if self.disk_list else ""
        self.disk_menu = tk.OptionMenu(self.root, self.selected_disk, *self.disk_list)
        self.disk_menu.grid(column=1, row=0, padx=10, pady=5, sticky="w")

        # 各チェックボックス
        self.secure_erase_val = tk.BooleanVar()
        self.secure_erase_val.set(False)
        self.secure_erase_checkbox = tk.Checkbutton(text="セキュアイレースを実行する", variable=self.secure_erase_val)
        self.secure_erase_checkbox.grid(column=1, row=1, padx=10, pady=5, sticky="w")

        self.throughput_val = tk.BooleanVar()
        self.throughput_val.set(False)
        self.throughput_checkbox = tk.Checkbutton(text="スループット測定を実行する", variable=self.throughput_val)
        self.throughput_checkbox.grid(column=1, row=2, padx=10, pady=5, sticky="w")

        self.latency_val = tk.BooleanVar()
        self.latency_val.set(False)
        self.latency_checkbox = tk.Checkbutton(text="レイテンシ測定を実行する", variable=self.latency_val)
        self.latency_checkbox.grid(column=1, row=3, padx=10, pady=5, sticky="w")

        # テキスト表示用のラベル
        self.result_label = tk.Label(text="")
        self.result_label.grid(column=1, row=4, padx=10, pady=5, sticky="w")

    def get_nvme_disks(self):
        # /dev/nvme* のディスクを取得する
        nvme_disks = [disk for disk in os.listdir("/dev") if disk.startswith("nvme")]
        return nvme_disks

    def execute_pcie_test_all(self):
        selected_disk = self.selected_disk.get()
        # 各チェックボックスの状態に応じて処理を行う
        if self.secure_erase_val.get() or self.throughput_val.get() or self.latency_val.get():
            if selected_disk:
                if self.secure_erase_val.get():
                    subprocess.run(["sudo", "bash", "pcie_test_all.sh", "h", selected_disk])
                if self.throughput_val.get():
                    subprocess.run(["sudo", "bash", "pcie_test_all.sh", "t", selected_disk])
                if self.latency_val.get():
                    subprocess.run(["sudo", "bash", "pcie_test_all.sh", "l", selected_disk])
                self.result_label.config(text="")
            else:
                self.result_label.config(text="ディスクを選択してください")
        else:
            self.result_label.config(text="ベンチマーク項目から選択してください")

if __name__ == "__main__":
    root = tk.Tk()
    app = BenchmarkApp(root)
    root.mainloop()
