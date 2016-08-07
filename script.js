document.documentElement.addEventListener('keydown', function (e) {
    if ( ( e.keycode || e.which ) == 32) {
        e.preventDefault();
    }
}, false);
