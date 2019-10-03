(function() {
    if (window.imy_realxhr) {
        return
    }
    window.imy_realxhr = XMLHttpRequest;
    let timestamp = new Date().getTime();
    timestamp = parseInt((timestamp / 1000) % 100000);
    let global_index = timestamp + 1;
    let global_map = {};

    window.imy_realxhr_callback = function(id, message) {
        console.log("window.imy_realxhr_callback");
        let xhr = global_map[id];
        if (xhr) {
            xhr.setRequestHeader("hook_post_request_id", id);
            xhr.origSend.apply(this, xhr.newFormData);
            xhr.newFormData = null;
        }
        global_map[id] = null
    };

    XMLHttpRequest.prototype.origSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.send = function() {
        console.log("XMLHttpRequest.prototype.send");
        if (arguments.length >= 1 && !!arguments[0]) {
            this.sendNative(arguments[0]);
        } else {
            this.origSend.apply(this, arguments);
        }
    };

    XMLHttpRequest.prototype.sendNative = function(formData) {
        console.log("XMLHttpRequest.prototype.sendNative");
        this.request_id = global_index;
        this.newFormData = formData;
        global_map[this.request_id] = this;
        global_index++;
        let message = {};
        message.id = this.request_id;
        message.formData = await converFormDataToCopyed(formData);
        window.webkit.messageHandlers.IMYXHR.postMessage(message)
    };
    
    async function converFormDataToCopyed(formData) {
        return new Promise((resolve, reject) => {
            let newFormData = new FormData();
            for(let pair of formData.entries()) {
                let key = pair[0];
                let value = pair[1];
                console.log(key + ', '+ value); 
                if( value instanceof Blob || value instanceof File) {
                    value = await getBase64(file);
                }
                newFormData.append(key,value);
            }
            resolve(newFormData);
          });
    }

    function getFileBase64(file) {
        return new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.readAsDataURL(file);
          reader.onload = () => resolve(reader.result);
          reader.onerror = error => reject(error);
        });
    }

    function converFormDataToCopyed(formData) {
        // Display the key/value pairs
        for(let pair of formData.entries()) {
            let key = pair[0];
            let value = pair[1];
            console.log(key + ', '+ value); 
            if( value instanceof Date ) {

            }
            if( value instanceof File ) {

            }
        }
    }
}
)();
