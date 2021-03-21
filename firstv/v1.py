from tkinter import *
from tkinter.scrolledtext import *
from tkinter.messagebox import *
from tkinter.filedialog import *
from markdown import *
from tkinterhtml import HtmlFrame

root = Tk()
#===
saved = IntVar()
file = StringVar()
file.set("None")

#===
def newf():
    savedvar = saved.get()
    if savedvar == 1:
        markdowncode_box.delete(1.0,"end")
        file.set("None")
        saved.set(1)
    else:
        if askyesno("New file ...", "The text isn't saved. Do you really like to make a new file ?"):
            markdowncode_box.delete(1.0,"end")
            file.set("None")
            saved.set(1)
        else:
            showinfo("New file ...", "Your text wasn't deleted.")
def savef():
    if file.get() == "None":
        saveasf()
    else:
        filet = open(file.get(), "w")
        filet.write(markdowncode_box.get(1.0, END))
def saveasf():
    filet = asksaveasfile(mode='w',defaultextension=".md")
    file.set(filet.name)
    filet.write(markdowncode_box.get(1.0, END))
def htmlasf():
    filet = asksaveasfile(mode='w',defaultextension=".html")
    htmltext = markdown(markdowncode_box.get(1.0, END))
    filet.write(htmltext)
def saveacaf():
    filet = asksaveasfile(mode='w',defaultextension=".md")
    filet.write(markdowncode_box.get(1.0, END))
#---
def boldt():
    markdowncode_box.insert(1.0, "**")
def italict():
    markdowncode_box.insert(1.0, "*")
def linet():
    markdowncode_box.insert(1.0, "---")
def aboutwin():
    pass
#---
def h1t():
    markdowncode_box.insert(1.0, "#")
def h2t():
    markdowncode_box.insert(1.0, "##")
def h3t():
    markdowncode_box.insert(1.0, "###")
def h4t():
    markdowncode_box.insert(1.0, "####")
def h5t():
    markdowncode_box.insert(1.0, "#####")
def h6t():
    markdowncode_box.insert(1.0, "######")
#---
menubar = Menu(root)

menu1 = Menu(menubar, tearoff=0)
menu1.add_command(label="New", command=newf)
menu1.add_separator()
menu1.add_command(label="Save", command=savef)
menu1.add_command(label="Save As", command=saveasf)
menu1.add_command(label="Save a Copy As ...", command=saveacaf)
menu1.add_separator()
menu1.add_command(label="Export As a HTML ...", command=htmlasf)
menu1.add_separator()
menu1.add_command(label="Exit", command=root.quit)
menubar.add_cascade(label="File", menu=menu1)

menu2 = Menu(menubar, tearoff=0)
menu2.add_command(label="Bold", command=boldt)
menu2.add_command(label="Italic", command=italict)
menu2.add_separator()
#---
headers_menu = Menu(menu2, tearoff=0)
headers_menu.add_command(label="Header 1", command=h1t)
headers_menu.add_command(label="Header 2", command=h2t)
headers_menu.add_command(label="Header 3", command=h3t)
headers_menu.add_command(label="Header 4", command=h4t)
headers_menu.add_command(label="Header 5", command=h5t)
headers_menu.add_command(label="Header 6", command=h6t)
#---
menu2.add_cascade(label="Headers", menu=headers_menu)
menu2.add_separator()
menu2.add_command(label="Line", command=linet)
menubar.add_cascade(label="Edit (Insert)", menu=menu2)

menu3 = Menu(menubar, tearoff=0)
menu3.add_command(label="About", command=aboutwin)
menu3.add_command(label="Help", command=aboutwin)
menubar.add_cascade(label="Help", menu=menu3)
#---
root.config(menu=menubar)
#===
markdowncode = LabelFrame(root, text="Markdown source")
markdowncode.pack(side=LEFT, expand=True, fill="both")
#---
htmlpreview = LabelFrame(root, text="Html preview")
htmlpreview.pack(side=RIGHT, expand=True, fill="both")
#---
markdowncode_box = ScrolledText(markdowncode)
markdowncode_box.pack(expand=True, fill="both")
#---
def refresh(event):
    markdowntxt = markdowncode_box.get("1.0", END)
    htmltext = markdown(markdowntxt)
    preview.set_content(htmltext)
    saved.set(0)

#---
markdowncode_box.bind("<Key>", refresh)
#---
preview = HtmlFrame(htmlpreview, horizontal_scrollbar="auto")
preview.pack(expand=True, fill="both")

#print(frame.html.cget("zoom"))


root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)
root.mainloop()
