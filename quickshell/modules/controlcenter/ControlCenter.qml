import qs.commonwidgets
import qs.services as S

BarGroupIconPopup {
    id: root
    mouseEnabled: true
    hoverEnabled: false
    iconSet: [S.Network.currentNetworkIcon, S.Bluetooth.currentBluetoothIcon, S.AudioService.currentAudioIcon, "⏻"]
}
