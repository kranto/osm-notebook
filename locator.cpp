#include "locator.h"

#include <QGeoPositionInfoSource>
#include <QGeoMapCircleObject>
#include <QDebug>

QTM_USE_NAMESPACE

Locator::Locator(QObject *parent)
        : QObject(parent),
          m_position(0)
{
    QGeoPositionInfoSource *source = QGeoPositionInfoSource::createDefaultSource(this);
    if (source) {
        source->setPreferredPositioningMethods(QGeoPositionInfoSource::SatellitePositioningMethods);
        connect(source, SIGNAL(positionUpdated(QGeoPositionInfo)),
                this, SLOT(positionUpdated(QGeoPositionInfo)));
        source->startUpdates();
    }
}

void Locator::positionUpdated(const QGeoPositionInfo &info)
{
//    qDebug() << "Position updated:" << info;
    m_position = new QGeoPositionInfo(info);
    emit positionChanged();
    if (m_position->isValid() && m_position->coordinate().isValid()) {
        m_track.append(new QGeoCoordinate(m_position->coordinate()));
        emit trackChanged();
    }
}


double Locator::latitude()
{
    if (m_position)
        return m_position->coordinate().latitude();
    else
        return 0;
}

double Locator::longitude()
{
    if (m_position)
        return m_position->coordinate().longitude();
    else
        return 0;
}

double Locator::altitude()
{
    if (m_position)
        return m_position->coordinate().altitude();
    else
        return 0;
}

qreal Locator::accuracy()
{
    if (m_position)
        return m_position->attribute(QGeoPositionInfo::HorizontalAccuracy);
    else
        return 0;
}

QDeclarativeListProperty<QGeoCoordinate> Locator::track()
{
    return QDeclarativeListProperty<QGeoCoordinate>(this, m_track);
}
