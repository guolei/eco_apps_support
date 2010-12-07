function filterNullValue(dom_id){
    $$('#'+dom_id+' input').each(function(dom){
        if(dom.value.blank()){
            dom.disable();
        }
    })

    $$('#'+dom_id+' select').each(function(dom){
        if(dom.value.blank()){
            dom.disable();
        }
    })

    $$('#'+dom_id+' input[type=submit]').invoke('disable');
}

function ajaxLoad(dom_id, url){
    var div = "#" + dom_id;
    $(div).load(url, function(response, status, xhr) {
        if (status == "error") {
            var msg = "There was an error when loading '" + url + "': ";
            $(div).html(msg + xhr.status + " " + xhr.statusText);
        }
    });
}