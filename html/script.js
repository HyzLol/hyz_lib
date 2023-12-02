window.addEventListener("message",(data) => {
    let item = data.data 
    if (item.type !== "textUi") return 

    if (item.toggle === true) {
        $("#text").html(item.text)
        $("#text").fadeIn()
    } else {
        $("#text").fadeOut()
    }
})