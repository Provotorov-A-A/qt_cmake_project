#include "mainwindow.h"
#include <QWidget>
#include <QVBoxLayout>
#include <QPushButton>

MainWindow::MainWindow(QWidget* parent)
{
	QWidget* centralWidget = new QWidget();
	QVBoxLayout* layout = new QVBoxLayout();;
	QPushButton* button = new QPushButton("Close");
	layout->addWidget(button);
	centralWidget->setLayout(layout);	
	this->setCentralWidget(centralWidget);
	
	connect(button, SIGNAL(pressed()), this, SLOT(close()));
}