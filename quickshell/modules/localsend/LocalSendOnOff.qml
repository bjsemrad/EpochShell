import qs.commonwidgets
import qs.services as S

// Accepting transfers holds the LocalSend port, which stops the desktop app from using it.
// Turning this off hands the port back.
SettingsToggleHeader {
    headerText: "LocalSend"
    checkedValue: S.LocalSend.receivingAvailable

    function handleToggled(checked) {
        S.LocalSend.setReceiving(checked);
    }
}
