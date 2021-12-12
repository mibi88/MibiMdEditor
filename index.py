from tkinter import *
from tkinter.scrolledtext import *
from tkinter.messagebox import *
from tkinter.filedialog import *
from markdown import *
from tkinterhtml import HtmlFrame
from time import *
from threading import Thread

root = Tk()
#---
root.title("MibiMdEditor")
#===
saved = 1
file = "None"
event_r = None
#===
def refreshtitle():
    global saved
    global file
    if saved == 0:
        title = "* MibiMdEditor - file : " + file + "*"
        root.title(title)
    else:
        title = "MibiMdEditor - file : " + file
        root.title(title)
refreshtitle()
def newf(event = None):
    global saved
    global file
    if saved == 1:
        markdowncode_box.delete(1.0,"end")
        file = "None"
        saved = 1
        refreshtitle()
    else:
        if askyesno("New file ...", "The text isn't saved. Do you really like to make a new file ?"):
            markdowncode_box.delete(1.0,"end")
            file = "None"
            saved = 1
            refreshtitle()
        else:
            showinfo("New file ...", "Your text wasn't deleted.")
def savef(event = None):
    global file
    global saved
    #print("savef")
    if file == "None":
        saveasf()
    else:
        filet = open(file, "w")
        filet.write(markdowncode_box.get(1.0, END))
        saved = 1
        filet.close()
        refreshtitle()
def saveasf(event=None):
    global file
    global saved
    filet = asksaveasfile(mode='w',defaultextension=".md")
    try:
        file = filet.name
        filet.write(markdowncode_box.get(1.0, END))
        saved = 1
        filet.close()
    except AttributeError:
        pass
    refreshtitle()
def htmlasf(event=None):
    filet = asksaveasfile(mode='w',defaultextension=".html")
    markdowntxt = markdowncode_box.get("1.0", END)
    htmltext = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/transitional.dtd"><html><head></head><body>'
    htmltext += markdown(markdowntxt, extensions=['extra', 'toc', 'smarty', 'legacy_attrs', 'meta'])
    htmltext += "</body></html>"
    htmltext = htmltext.replace("<table>",'<table border="2" >')
    htmltext = htmltext.replace("<code>",'<code bgcolor="#DCDCDC" >')
    # print(htmltext)
    filet.write(htmltext)
    filet.close()
def saveacaf():
    filet = asksaveasfile(mode='w',defaultextension=".md")
    try:
        filet.write(markdowncode_box.get(1.0, END))
        filet.close()
    except AttributeError:
        pass
def openf(event=None):
    global saved
    global file
    if saved == 0:
        if askyesno("Open a file ...", "Your text isn't saved. Do you really want to open a file ?"):
            filename = askopenfilename(title="Ouvrir votre document",filetypes=[("Markdown Files",".md"),("Markdown Files",".markdown"),("all files",".*"), ("all files","*")])
            filet = open(filename, "r")
            try:
                text = filet.read()
            except UnicodeDecodeError:
                showerror("UnicodeDecodeError", "Broken file.")
            markdowncode_box.delete(1.0, END)
            markdowncode_box.insert(1.0, text)
            saved = 1
            file = filename
    else:
        filename = askopenfilename(title="Ouvrir votre document",filetypes=[("Markdown Files",".md"),("Markdown Files",".markdown"),("all files",".*"), ("all files","*")])
        filet = open(filename, "r")
        try:
            text = filet.read()
        except UnicodeDecodeError:
            showerror("UnicodeDecodeError", "Broken file.")
        markdowncode_box.delete(1.0, END)
        markdowncode_box.insert(1.0, text)
        saved = 1
        file = filename
    #---
    file = filename
    saved = 1
    filet.close()
    refreshtitle()
#---
def boldt(event=None):
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "**")
def italict(event=None):
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "*")
def linet():
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "---")
def aboutwin():
    showinfo("About", "MibiMdEditor\n_______________\nby mibi88\n_______________\nVersion : v.0.1\nLicense :\nGNU GPL v2\n_______________\nThank you for\nusing this app !")
def helpwin(event=None):
    showinfo("Help", "MibiMdEditor\n_______________\nby mibi88\n_______________\nSee README.md\n_______________")

#---
def h1t():
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "#")
def h2t():
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "##")
def h3t():
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "###")
def h4t():
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "####")
def h5t():
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "#####")
def h6t():
    cursor_pos = markdowncode_box.index(INSERT)
    markdowncode_box.insert(cursor_pos, "######")
#---
def askexit(event=None):
    global saved
    if saved == 0:
        if askyesno("Quit ...", "Your file isn't saved ! Do you really want to quit ?"):
            root.quit()
    else:
        root.quit()
def undot():
    markdowncode_box.edit_undo()
def redot():
    markdowncode_box.edit_redo()
#---
menubar = Menu(root)

menu1 = Menu(menubar, tearoff=0)
menu1.add_command(label="New                            Ctrl+N", command=newf)
menu1.add_separator()
menu1.add_command(label="Save                           Ctrl+S", command=savef)
menu1.add_command(label="Save As                      Ctrl+Maj+S", command=saveasf)
menu1.add_command(label="Save a Copy As ...", command=saveacaf)
menu1.add_separator()
menu1.add_command(label="Open", command=openf)
menu1.add_separator()
menu1.add_command(label="Export As a HTML ...   Ctrl+E", command=htmlasf)
menu1.add_separator()
menu1.add_command(label="Exit   Ctrl+Q", command=askexit)
menubar.add_cascade(label="File", menu=menu1)

menu2 = Menu(menubar, tearoff=0)
menu2.add_command(label="Bold       Ctrl+B", command=boldt)
menu2.add_command(label="Italic      Ctrl+I", command=italict)
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
menu2.add_separator()
menu2.add_command(label="Undo      Ctrl+Z", command=undot)
menu2.add_command(label="Redo      Ctrl+Y", command=redot)
menubar.add_cascade(label="Edit (Insert)", menu=menu2)

menu3 = Menu(menubar, tearoff=0)
menu3.add_command(label="About", command=aboutwin)
menu3.add_command(label="Help   Ctrl+H", command=helpwin)
menubar.add_cascade(label="Help", menu=menu3)
#---
root.config(menu=menubar)
#===
mainpanel = PanedWindow(root, orient=HORIZONTAL)
#===
markdowncode = LabelFrame(root, text="Markdown source")
markdowncode.pack(side=LEFT, expand=True, fill="both")
mainpanel.add(markdowncode)
#---
htmlpreview = LabelFrame(root, text="Html preview")
htmlpreview.pack(side=RIGHT, expand=True, fill="both")
mainpanel.add(htmlpreview)
#---
mainpanel.pack(expand=True, fill="both")
#---
markdowncode_box = ScrolledText(markdowncode, wrap="word", undo=True)
markdowncode_box.pack(expand=True, fill="both")
#---
def refreshth(event_r_a):
    global event_r
    event_r = event_r_a
    mainthread=Thread(target = refresh)
    mainthread.start()
def refresh():
    global event_r
    sleep(0.1)
    markdowntxt = markdowncode_box.get("1.0", END)
    htmltext = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/transitional.dtd"><html><head></head><body>'
    htmltext += markdown(markdowntxt, extensions=['extra', 'toc', 'smarty', 'legacy_attrs', 'meta'])
    htmltext += "</body></html>"
    htmltext = htmltext.replace("<table>",'<table border="2" >')
    htmltext = htmltext.replace("<code>",'<code bgcolor="#DCDCDC" >')
    # print(htmltext)
    preview.set_content(htmltext)
    if not "Control" in event_r.keysym:
        saved = 0
        refreshtitle()

#---
markdowncode_box.bind("<Key>", refreshth)
#---
root.bind_all('<Control-S>', savef)
root.bind_all('<Control-Shift-S>', saveasf)
root.bind_all('<Control-Q>', askexit)
root.bind_all('<Control-E>', htmlasf)
root.bind_all('<Control-B>', boldt)
root.bind_all('<Control-I>', italict)
root.bind_all('<Control-H>', helpwin)
root.bind_all('<Control-N>', newf)
root.protocol("WM_DELETE_WINDOW", askexit)
#---
preview = HtmlFrame(htmlpreview, horizontal_scrollbar="auto")
preview.pack(expand=True, fill="both")

#print(frame.html.cget("zoom"))

root.mainloop()
