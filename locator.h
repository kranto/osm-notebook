#ifndef LOCATOR_H
#define LOCATOR_H

#include <QObject>
#include <QList>
#include <QGeoPositionInfo>
#include <QGeoCoordinate>
#include <QGeoMapObject>
#include <QDeclarativeListProperty>

QTM_USE_NAMESPACE

class Locator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double latitude READ latitude NOTIFY positionChanged)
    Q_PROPERTY(double longitude READ longitude NOTIFY positionChanged)
    Q_PROPERTY(double altitude READ altitude NOTIFY positionChanged)
    Q_PROPERTY(qreal accuracy READ accuracy NOTIFY positionChanged)
    Q_PROPERTY(QDeclarativeListProperty<QGeoCoordinate> track READ track NOTIFY trackChanged)

public:
    Locator(QObject *parent = 0);

    double latitude();
    double longitude();
    double altitude();
    qreal accuracy();

    QDeclarativeListProperty<QGeoCoordinate> track();

signals:
    void positionChanged();
    void trackChanged();

private slots:
    void positionUpdated(const QGeoPositionInfo &info);

private:
    QGeoPositionInfo *m_position;
    QList<QGeoCoordinate*> m_track;
};

#endif // LOCATOR_H
