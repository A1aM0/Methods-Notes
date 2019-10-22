import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ApplicationWindow {

    id: window;
    width: 320;
    height: 480;
    visible: true;

    property real pixelDensity: Screen.pixelDensity * 25.4 /160 //获取当前屏幕dp

    // 不同像素间的换算倍率
    property real multiplierH: window.height/480 // 当前窗口与基准画布高度之比
    property real multiplierW: window.width/320 // 当前窗口与基准画布宽度之比
    
    // 换算为实际像素
    function dpH(numbers) {
        return Math.round(numbers*pixelDensity*multiplierH);
    }
    function dpW(numbers) {
        return Math.round(numbers*pixelDensity*multiplierW);
    }

    Rectangle{
        anchors.fill: parent
        Text{
            anchors.topMargin: dpH(240)
            anchors.leftMargin: dpW(160)
            anchors.left: parent.left
            anchors.top: parent.top
            width: dpW(80)
            height: dpH(120)
            
            text: "中国，是以华夏文明为源泉、中华文化为基础，并以汉族为主体民族的多民族国家，通用汉语、汉字，汉族与少数民族被统称为“中华民族”，又自称为炎黄子孙、龙的传人。"
            font.pointSize: 10
            wrapMode: Text.Wrap
        }
    }
}
