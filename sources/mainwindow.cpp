#include <QWidget>
#include <QVBoxLayout>

#include "mainwindow.h"

MainWindow::MainWindow(QWidget* parent)
{
    QLayout* mainLayout = Layout();
	setLayout(mainLayout);	
    Connections();
    show();
}

QLayout *MainWindow::Layout()
{
    QVBoxLayout* layout = new QVBoxLayout();
	m_textEdit = new QTextEdit();
    m_closeButton = new QPushButton("Close");
    layout->addWidget(m_textEdit);
    layout->addWidget(m_closeButton);
    return layout;
}

void MainWindow::Connections()
{
    connect(m_closeButton, SIGNAL(pressed()), this, SLOT(close()));    
}

