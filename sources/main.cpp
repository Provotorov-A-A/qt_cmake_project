#include <QApplication>
#include <QDebug>
#include <QStyle>
#include <QStyleFactory>
#include <QMainWindow>

#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;
    w.show();
    
    return a.exec();
}
