$('#msgTrigger').on('click', function (e) {
    var msg = $('#inputArg').val();
    $('#inputArg').val("");
    $("#messageQueue").prepend("<div class=\"message_container\"><div class=\"message_user\">" + msg + "</div></div>");
    $.post("api/v1/post", {args: msg}, function(result){
        $("#messageQueue").prepend("<div class=\"message_container\"><div class=\"message_jeff\">" + result + "</div></div>");
    });
})
