function filterNullValue(dom_id){
    var inputs = $('#' + dom_id + ' :input');

    var filter = ["utf8", "commit"];

    inputs.each(function() {
        if($(this).val() == "" || $.inArray(this.name, filter) >= 0){
            $(this).attr("disabled", true);
        }
    });
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