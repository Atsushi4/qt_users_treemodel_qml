#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <QtCore/QFileSystemWatcher>
#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtGui/QStandardItem>
#include <QtGui/QStandardItemModel>

QStringList qmlFiles(const QString &parent)
{
    QStringList files;
    for (auto entry : QDir{parent}.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries)) {
        if (entry.isDir()) {
            files.append(qmlFiles(entry.absoluteFilePath()));
        } else {
            files.append(entry.absoluteFilePath());
        }
    }
    return files;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickView view;
    auto qmlRoot = QStringLiteral("qml/");
    QFileSystemWatcher watcher(qmlFiles(qmlRoot));
    auto reload = [&](const QString &path){
        QFileInfo info(path);
        if (info.isFile() && info.suffix() != "qml" && info.suffix() != "js") return;
        qDebug() << "reload" << path;
        view.engine()->clearComponentCache();
        view.setSource(QUrl::fromLocalFile(qmlRoot + QStringLiteral("main.qml")));
        if (path.isEmpty()) return;
        watcher.removePaths(watcher.files());
        watcher.addPaths(qmlFiles(qmlRoot));
    };
    // [1] サンプル用のツリー構造のモデルを作る
    QStandardItemModel model;
    for (int i = 0; i < 100; ++i) {
        auto row = new QStandardItem(QString("item_%1").arg(i+1));
        QList<QStandardItem*> children;
        for (int j = 0; j < 1000; ++j) {
            auto child = new QStandardItem(QString("item_%1_%2").arg(i+1).arg(j+1));
            child->setData(QColor(static_cast<Qt::GlobalColor>((j % 10) + Qt::red)), Qt::DecorationRole);
            children.append(child);
        }
        row->appendRows(children);
        model.appendRow(row);
    }
    view.rootContext()->setContextProperty("dataModel", &model);
    // [1] ここまで
    QObject::connect(&watcher, &QFileSystemWatcher::fileChanged, &app, reload, Qt::QueuedConnection);

    reload({});
    view.show();
    return app.exec();
}
