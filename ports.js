function startPorts(elm) {
    elm.ports.urlReceiver.send(window.location.href)

    elm.ports.sendSetPageQuery.subscribe((query) => {
        if (query !== "") {
            history.pushState({}, "", `?file=${query}`)
        } else {
            history.pushState({}, "", "/")
        }
    })

    elm.ports.sendSetClipboard.subscribe(async () => {
        await navigator.clipboard.writeText(window.location.href)
    })
}
