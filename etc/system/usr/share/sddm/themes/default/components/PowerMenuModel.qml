import QtQuick 2.11
import QtQml.Models 2.2

DelegateModel {
    items.includeByDefault: false
    persistedItems.includeByDefault: true
    model: ListModel {
        ListElement {
            icon: "system-suspend.svgz"
            text: function() { return theme.text.suspend; }
            action: function() { if (sddm.canHybridSleep) sddm.hybridSleep(); else sddm.suspend(); }
        }
        ListElement {
            icon: "system-hibernate.svgz"
            text: function() { return theme.text.hibernate; }
            action: function() { sddm.hibernate(); }
        }
        ListElement {
            icon: "system-reboot.svgz"
            text: function() { return theme.text.reboot; }
            action: function() { sddm.reboot(); }
        }
        ListElement {
            icon: "system-shutdown.svgz"
            text: function() { return theme.text.shutdown; }
            action: function() { sddm.powerOff(); }
        }
    }

    signal update
    onUpdate: {
        persistedItems.get(0).inItems = sddm.canSuspend || sddm.canHybridSleep
        persistedItems.get(1).inItems = sddm.canHibernate
        persistedItems.get(2).inItems = sddm.canReboot
        persistedItems.get(3).inItems = sddm.canPowerOff
    }
}
