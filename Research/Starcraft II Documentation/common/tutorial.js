jQuery.extend( jQuery.easing,
    {
        easeOutCubic: function (x, t, b, c, d) {
            return c*((t=t/d-1)*t*t + 1) + b;
        }
    }
);

function HideMenu ( menu ) {
    menu.slideUp();
    menu.addClass( 'closed' );
    //menu.parent().animate( {paddingBottom:'5px'}, 150 );
}

function ShowMenu ( menu ) {
    menu.slideDown();
    menu.removeClass( 'closed' );
    //menu.parent().animate( {paddingBottom:'0px'}, 150 );
}

function LocateLink ( page ) {
    var query = '.nav a[href$="' + page + '"]';
    return $(query,window.parent.frames[0].document);
}

function SetCurrentLink ( link ) {
    $('a',window.parent.frames[0].document).removeClass( 'current' );
    link.addClass( 'current' );
}

function UpdateMenu () {
    var path = window.parent.frames[1].location.href;
    if( path ) {
        var page = path.substring(path.lastIndexOf('/') + 1);
        link = LocateLink( page );
        SetCurrentLink( link );
        ShowMenu(link.parents('ul ul'));
        
    }
}

function ResolveFocus () {
    $(".focus").each(function() {
        var focus = $(this);
        var hiddenTop = $(window).scrollTop() - focus.data("originalOffset");
   
        // Clamp for window not having scrolled past the element
        if( hiddenTop < 0)
            hiddenTop = 0;
        
        // Compensate for item wanting to scroll past bounds
        var distanceToBottom = focus.data("originalPosition") + focus.data("originalRemainder");
        if( hiddenTop > focus.parent().innerHeight() - distanceToBottom) {
            hiddenTop = focus.parent().innerHeight() - distanceToBottom;
        }
        
        // Clamp for image that is bigger than the natural height of the contianer
        if( hiddenTop < 0)
            hiddenTop = 0;
            
        // Have a potential amount to scroll down
        var target = hiddenTop;
        
        // If the image is larger than the screen,  reduce scroll, so image is centered
        var total = hiddenTop + focus.data("originalOffset") + focus.data("originalRemainder");
        var scrollBot = $(window).scrollTop() + $(window).height();
        var overflow = total - scrollBot;
        if ( overflow > 0 )
        {
            var docRemainder = focus.parent().innerHeight() - focus.data("originalMarginTop");
            var scroll = (hiddenTop) / (docRemainder - $(window).height());
            
            target = target - overflow * scroll;
        }
        
        // Never scroll backwards
        if( target < 0 )
            target = 0;
        
        // Include original aesthetic spacing.
        target = target + focus.data("originalMarginTop");
        
        // Queue animation
        focus.stop().animate({"marginTop": ( target + "px" )}, "slow", "easeOutCubic" );
            
    });
}

$(document).ready(function() {
    
    // Shrink UI
    HideMenu($('.nav ul ul'));
    //$('.nav ul ul').slideUp('slow');
    //$('.nav ul ul').addClass('closed');
    UpdateMenu();

    // Format minimized list
    $('.nav ul li a').each(function(){
        
        // Change border shape to be a dagger for expanding items
        var submenu = $(this).parent().children('ul');
        if (submenu.length > 0) {
            $(this).parent().css( 'border-bottom', '6px solid #DDE' );
        }
        
        // Mark deadends
        else if( $(this).attr('href') == "javascript:void(0);" ) {
            $(this).css( 'color', '#888' );
        }
    });
    
    // Expand actual items
    $('.nav ul li a').click(function(){
        var submenu = $(this).parent().children('ul');

        // Clicked a slider, toggle display
        if (submenu.length > 0) {
            if( submenu.hasClass( 'closed' ) ) {
                ShowMenu( submenu )
            }
            else {
                HideMenu( submenu )
            }
            
            return false;
        }
        
        // Mute dummy anchor links for not-yet-created pages.
        if ( $(this).attr('href') == "#" ) {
            return false;
        }
        
        return true;
    });
    
    
    $('.content a').each( function(){
        url = $(this).attr('href');
        var regPrefix = "http://";
        var secPrefix = "https://";
        if (   url.substring(0, regPrefix.length) === regPrefix
            || url.substring(0, secPrefix.length) === secPrefix ) {
            $(this).attr('target', '_Top');
        }
    });
});

    
$(window).load(function() {   
    $('.zoom').each(function() {
        var node = $(this);
        node.data( 'largewidth', node.width() );
        node.data( 'largeheight', node.height() );
        
        $(this).animate( { width: node.data("largewidth") * .5, height: node.data("largeheight") * .5 } );
    });
    
    $('.zoom').click(function(){
        var node = $(this);
        if( node.hasClass( "expanded" ) ) {
            $(this).animate( { width: node.data("largewidth") * .5, height: node.data("largeheight") * .5 }  );
            node.removeClass( "expanded" );
        }
        else
        {
            $(this).animate( { width: node.data("largewidth"), height: node.data("largeheight") } );
            node.addClass( "expanded" );
        }
    });
    
    var focus = $(".focus");
    
    focus.each(function(){
        var node = $(this);
        
        var top = parseInt( node.css("margin-top").replace( "px", ""));
        var remainder = node.outerHeight(true) - top;
        
        var totalOffset = parseInt(node.offset().top);
        var relativeOffset = top + totalOffset - parseInt(node.parent().offset().top);
        
        
        node.data( 'originalMarginTop', top );
        node.data( 'originalRemainder', remainder );
        node.data( 'originalOffset', totalOffset );
        node.data( 'originalPosition', relativeOffset );
        
        var sibs = node.nextAll();
        sibs.each(function(){
            var sib = $(this);
            sib.css( 'marginRight', parseInt( sib.css('marginRight').replace( "px", "" ) ) + node.outerWidth(true) + "px" );
        });
    });
 
    $(window).scroll( ResolveFocus );
    $(window).resize( ResolveFocus );
});