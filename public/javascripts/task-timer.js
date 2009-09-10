function format_seconds_as_time(secs)
{
    var minutes = String(Math.floor(secs / 60));
    var seconds = secs % 60;
    var stringseconds = "";

    if(seconds < 10) {
        stringseconds = "0" + seconds;
    } else {
        stringseconds = String(seconds);
    }

    return minutes + ":" + stringseconds;
}

function timer_done()
{
    new Effect.Appear('timeout-overlay', { duration: 0.5, to: 0.8 });
    $('timeout-message').show();
    setTimeout("$('work-form').submit()", 3000);
}

function run_timer(secs)
{
    if(secs < 0) {
        timer_done();
    } else {
        $('task-timer').update(format_seconds_as_time(secs));
        if((secs + 5) % 10 == 0) {
            var serversecs = "" + secs;
            new Ajax.Request('/experiment/seconds_remaining', { asynchronous: false,
                        onSuccess: function(r) { serversecs = r.responseText; } } );
            if(!isNaN(parseInt(serversecs))) {
                secs = parseInt(serversecs);
            }
        }
        if(secs == 0) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#000000', endcolor: '#ff0000',
                                         restorecolor: '#ff0000' });
        } else if(secs == 30) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#330000', endcolor: '#000000' });
        } else if(secs == 25) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#660000', endcolor: '#000000' });
        } else if(secs == 20) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#990000', endcolor: '#000000' });
        } else if(secs == 15) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#cc0000', endcolor: '#000000' });
        } else if(secs <= 10) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#ff0000', endcolor: '#000000' });
        }
        setTimeout('run_timer(' + (secs - 1) + ')', 1000);
    }
}

function tutorial_timer(secs)
{
    if(secs >= 0) {
        $('task-timer').update(format_seconds_as_time(secs));
        if(secs == 0) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#000000', endcolor: '#ff0000',
                                         restorecolor: '#ff0000' });
        } else if(secs == 30) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#330000', endcolor: '#000000' });
        } else if(secs == 25) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#660000', endcolor: '#000000' });
        } else if(secs == 20) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#990000', endcolor: '#000000' });
        } else if(secs == 15) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#cc0000', endcolor: '#000000' });
        } else if(secs <= 10) {
            new Effect.Highlight('task-timer',
                                 { startcolor: '#ff0000', endcolor: '#000000' });
        }
        setTimeout('tutorial_timer(' + (secs - 1) + ')', 1000);
    }
}

