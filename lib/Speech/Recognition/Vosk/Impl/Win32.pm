package Speech::Recognition::Vosk::Impl::Win32;
use strict;
use 5.012;
use File::Basename 'dirname';
use Win32::API;
use Exporter 'import';
use File::ShareDir 'dist_dir';

# We want to load the DLLs from here:
sub load_libvosk {
    my ($path) = @_;
    $path //= dist_dir('Speech::Recognition::Vosk::Impl::Win32');
    local $ENV{PATH} .= ";" . $path;

    Win32::API::More->Import("libvosk.dll", "vosk_model_new", "P", "N")
        or die $^E;

    Win32::API::More->Import("libvosk.dll", "vosk_model_find_word", "NP", "N")
        or die $^E;

    Win32::API::More->Import("libvosk.dll", "vosk_recognizer_new", "NF", "N")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_accept_waveform", "NPN", "N")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_partial_result", "N", "P")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_result", "N", "P")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_final_result", "N", "P")
        or die $^E;
}

our @EXPORT_OK = (qw(
    model_new
    model_find_word
    model_recognizer_new
    model_recognizer_accept_waveform
    model_recognizer_partial_result
    model_recognizer_result
    model_recognizer_final_result
));

load_libvosk();

1;
