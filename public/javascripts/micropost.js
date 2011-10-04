function textInputAction()
{
    var countdown = document.getElementById('micropostLengthCount');
    var textarea = document.getElementById('micropost_content');
    var maxlimit = 200;
    if (textarea.value.length > maxlimit)
        textarea.value = textarea.value.substring(0, maxlimit);
    else{
        jQuery('#micropostLengthCount').removeClass('display_none');
        countdown.value = '  ('+(maxlimit-textarea.value.length)+' characters left)';
        toggleSubmitEnable();
    }    
}
    
function enlargeTextArea(){
    document.getElementById('micropost_content').style.height = "5em";    
}    
    
function toggleSubmitEnable(){
    var textarea = document.getElementById('micropost_content');
    var micropost_submit = document.getElementById('micropost_submit');
    if (textarea.value.length > 0)
        micropost_submit.disabled = false;
    else
        micropost_submit.disabled = true;
}    
    
window.onload = function () {
    var micropost_submit = document.getElementById('submitbutton');
    micropost_submit.style.display = 'block';
    toggleSubmitEnable();
}