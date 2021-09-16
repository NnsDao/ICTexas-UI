import { pokerMap,  actionMap, playerMap, avatarMap, operationMap } from './pages/Game/resource'

function image2Base64(img) {
    var canvas = document.createElement("canvas");
    canvas.width = img.width;
    canvas.height = img.height;
    var ctx = canvas.getContext("2d");
    ctx.drawImage(img, 0, 0, img.width, img.height);
    var dataURL = canvas.toDataURL("image/png");
    return dataURL;
}

function getImgBase64(imageUrl){
    return new Promise((resolve) => {
        var img = new Image();
        img.src = imageUrl;
        img.onload = () => {
            resolve(image2Base64(img))
        }
        img.onerror = () => {
            getImgBase64(imageUrl)
        }
    })

}

[pokerMap, actionMap, playerMap, avatarMap, operationMap].forEach(imageMap => {
    imageMap.forEach(async (imageUrl, name) => {
        if (!localStorage.getItem(name)) {
            const base64 = await getImgBase64(imageUrl)
            localStorage.setItem(name, base64)
        }
    })
})