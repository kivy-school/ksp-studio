import ElementaryUI
import ElementaryViews
import JavaScriptKit

/// Kivy's `ServicesModal` offers a start-type dropdown backed by a
/// `CRadioGroup`; `ServiceData.startType` itself is stored as a plain
/// `String` (matches the Python model), so this local enum exists purely to
/// drive `SelectField` without changing the model's wire shape.
enum ServiceStartType: String, CaseIterable {
    case sticky = "START_STICKY"
    case notSticky = "START_NOT_STICKY"
    case redeliverIntent = "START_REDELIVER_INTENT"
}

@View
struct AndroidServicesTab {
    var section: KivySchoolData.AndroidData
    @State var editingService: KivySchoolData.AndroidData.ServiceData? = nil

    var body: some View {
        div(.class("space-y-4")) {
            button(.class("bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded cursor-pointer")) {
                "+ Add service"
            }
            .onClick { _ in
                let newService = KivySchoolData.AndroidData.ServiceData()
                section.services.append(newService)
                editingService = newService
            }

            if section.services.isEmpty {
                p(.class("text-sm text-gray-400 dark:text-gray-500")) { "No services yet." }
            } else {
                div(.class("grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4")) {
                    for service in section.services {
                        AndroidServiceCard(
                            service: service,
                            onEdit: { editingService = service },
                            onDelete: { section.services.removeAll { $0 === service } }
                        )
                    }
                }
            }
        }

        if let service = editingService {
            AndroidServiceFormModal(service: service, onDismiss: { editingService = nil })
        }
    }
}

@View
struct AndroidServiceCard {
    var service: KivySchoolData.AndroidData.ServiceData
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        Card {
            div(.class("space-y-3")) {
                div(.class("flex items-start justify-between gap-2")) {
                    h4(.class("font-semibold text-gray-800 dark:text-gray-100 truncate")) { service.name }
                    div(.class("flex gap-1 flex-shrink-0")) {
                        button(.class("text-gray-400 hover:text-indigo-600 text-sm cursor-pointer px-1")) { "✎" }
                            .onClick { _ in onEdit() }
                        button(.class("text-gray-400 hover:text-red-600 text-sm cursor-pointer px-1")) { "✕" }
                            .onClick { _ in onDelete() }
                    }
                }
                div(.class("flex items-center gap-2 text-xs flex-wrap")) {
                    span(.class("px-2 py-0.5 rounded-full \(service.foreground ? "bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300" : "bg-gray-100 text-gray-500 dark:bg-gray-700 dark:text-gray-400")")) {
                        service.foreground ? "Foreground" : "Background"
                    }
                    span(.class("px-2 py-0.5 rounded-full bg-indigo-100 text-indigo-700 dark:bg-indigo-900 dark:text-indigo-300")) {
                        service.startType
                    }
                }
                if service.foreground, let type = service.foregroundServiceType, !type.isEmpty {
                    p(.class("text-xs text-gray-500 dark:text-gray-400")) { "Type: \(type)" }
                }
                p(.class("text-xs text-gray-400 dark:text-gray-500 truncate")) {
                    "Entrypoint: \(service.entrypoint)"
                }
            }
        }
    }
}

@View
struct AndroidServiceFormModal {
    var service: KivySchoolData.AndroidData.ServiceData
    var onDismiss: () -> Void

    var body: some View {
        div(.class("fixed inset-0 z-50 flex items-center justify-center p-4")) {
            div(.class("absolute inset-0 bg-black/50")) { "" }
                .onClick { _ in onDismiss() }

            div(.class("relative bg-white dark:bg-gray-800 rounded-lg shadow-2xl w-full max-w-lg max-h-[85vh] overflow-y-auto")) {
                div(.class("flex items-center justify-between px-6 py-4")) {
                    h3(.class("font-semibold text-gray-800 dark:text-gray-100")) { "Android Service" }
                    button(.class("text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 text-lg leading-none cursor-pointer")) { "✕" }
                        .onClick { _ in onDismiss() }
                }
                .border(.separator, edges: .bottom)

                div(.class("p-6 space-y-1")) {
                    FormField(
                        fieldLabel: "Service name",
                        value: #Binding(service.name),
                        helperText: "e.g. MyService",
                        placeholder: "MyService"
                    )
                    BoolField(fieldLabel: "Foreground", value: #Binding(service.foreground))
                    div(.class(service.foreground ? "" : "opacity-40 pointer-events-none")) {
                        FormField(
                            fieldLabel: "Foreground service type",
                            value: Binding(
                                get: { service.foregroundServiceType ?? "" },
                                set: { service.foregroundServiceType = $0.isEmpty ? nil : $0 }
                            ),
                            helperText: "e.g. location|dataSync|mediaPlayback",
                            placeholder: "location|dataSync"
                        )
                    }
                    SelectField(
                        fieldLabel: "Start type",
                        selection: Binding(
                            get: { ServiceStartType(rawValue: service.startType) ?? .notSticky },
                            set: { service.startType = $0.rawValue }
                        )
                    )
                    FormField(
                        fieldLabel: "Entrypoint",
                        value: #Binding(service.entrypoint),
                        helperText: "Python file as a python module",
                        placeholder: "yourapp.services.myservice"
                    )
                    FormField(
                        fieldLabel: "Notification title",
                        value: #Binding(service.notificationTitle),
                        placeholder: "MyService is running"
                    )
                    FormField(
                        fieldLabel: "Notification text",
                        value: #Binding(service.notificationText),
                        placeholder: "Performing background tasks"
                    )
                    FormField(
                        fieldLabel: "Notification icon",
                        value: #Binding(service.notificationIcon),
                        placeholder: "stat_notify_sync"
                    )
                }

                div(.class("flex justify-end gap-2 px-6 py-4")) {
                    button(.class("px-4 py-2 text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-gray-800 dark:hover:text-gray-100 cursor-pointer")) { "Done" }
                        .onClick { _ in onDismiss() }
                }
                .border(.separator, edges: .bottom)
            }
        }
        .onKeyDown { event in
            if event.key == "Escape" { onDismiss() }
        }
    }
}
