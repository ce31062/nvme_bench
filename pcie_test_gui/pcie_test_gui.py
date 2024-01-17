import tkinter as tk
import subprocess

# ウインド画面の設定
win = tk.Tk()
win.title("NVMe Benchmark tool for Linux")
win.geometry("500x300")

# ラベル(変数名:label)の作成
label = tk.Label(text="終わったタスクにチェックを入れて実行ボタンを押してください")
label.place(x=30, y=5)

# チェックボタン(変数名:Check_button)の作成
Check_val = tk.BooleanVar()
Check_val.set(False)
Check_button = tk.Checkbutton(text="タスク", variable=Check_val)
Check_button.place(x=30, y=30)

# ボタンを押したらチェックがついてるタスクの数を確認し、チェックの数を表示
def execute_pcie_test():
    if Check_val.get() == True:
        text = tk.Label(text="タスクは終了しました")
        text.place(x=100, y=62)
        subprocess.run(["./pcie_test_all.sh"])
    else:
        text = tk.Label(text="タスクは未解決です", foreground="red")
        text.place(x=100, y=62)

# ボタン(変数名:Button)の作成
Button = tk.Button(win, width=5, background="#ffffff", text="実行", command=execute_pcie_test)
Button.place(x=30, y=60)

# ウインドの表示
win.mainloop()

