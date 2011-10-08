#include <QtGui/QApplication>
#include <QtDeclarative>

#include "locator.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;
//    Locator l;
//    view.rootContext()->setContextProperty("locator", &l);
    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.showFullScreen();
    return app.exec();
}
