#include <QWidget>
#include <QTextEdit>
#include <QLayout>
#include <QPushButton>

class MainWindow : public QWidget
{
	Q_OBJECT
public:
    explicit MainWindow(QWidget* parent = nullptr);

private:
    QLayout* Layout();
    void Connections();
	
private:
	QTextEdit* m_textEdit;
    QPushButton* m_closeButton;
};
