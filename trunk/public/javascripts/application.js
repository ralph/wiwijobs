// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function init()
{
	if ($('flash_error').innerHTML.toString() != "") showFlashError();
	if ($('flash_notice').innerHTML.toString() != "") showFlashNotice();
	
	// Lightbox effect
	var mylb = Class.create();
	mylb.prototype = {
		initialize: function(ctrl)
		{
			this.content = ctrl.href;
			Event.observe(ctrl, 'click', this.activate.bindAsEventListener(this), false);
			ctrl.onclick = function(){return false;};
		},
	
		// Turn everything on - mainly the IE fixes
		activate: function()
		{
			var win = new Window('window_id', {className: "mylightbox", resizable:false, closable: false, minimizable: false, maximizable: false, draggable: false, url: this.content, width:700, height:500});
			win.setDestroyOnClose();
			win.showCenter(true);
		}
	}
	
	lbox = document.getElementsByClassName('lightbox');
	for(i = 0; i < lbox.length; i++)
	{
		valid = new mylb(lbox[i]);
	}
	// Lightbox effect end	
}

function showFlashError()
{
	Effect.Appear('flash_error');
}

function showFlashNotice()
{
	Effect.Appear('flash_notice');
}
