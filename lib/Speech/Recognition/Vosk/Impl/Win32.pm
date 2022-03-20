package Speech::Recognition::Vosk::Impl::Win32;
use strict;
use 5.012;
use File::Basename 'dirname';
use Win32::API;
use Exporter 'import';
use File::ShareDir 'dist_dir';

our $VERSION = '0.03';
our @EXPORT_OK = (qw(
    model_new
    model_find_word
    model_recognizer_new
    model_recognizer_free
    model_recognizer_accept_waveform
    model_recognizer_partial_result
    model_recognizer_result
    model_recognizer_final_result
));

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

    Win32::API::More->Import("libvosk.dll", "vosk_recognizer_free", "N", "N")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_accept_waveform", "NPN", "N")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_partial_result", "N", "P")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_result", "N", "P")
        or die $^E;

    Win32::API->Import("libvosk.dll", "vosk_recognizer_final_result", "N", "P")
        or die $^E;

    # Make the names available without their "vosk_" prefix:
    for my $name (@EXPORT_OK) {
        no strict 'refs';
        my $imported = "vosk_" . $name;
        *{ $name } = \&{$imported};
    }
}

load_libvosk();

1;

=head1 NAME

Speech::Recognition::Vosk::Impl::Win32 - Win32 library for the Vosk toolkit

=head1 SYNOPSIS

Most likely, you want to use the more convenient OO wrapper in
L<Speech::Recognition::Vosk::Recognizer>.

  use Speech::Recognition::Vosk::Impl::Win32 qw(
  );
  use JSON 'decode_json';

  my $model = Speech::Recognition::Vosk::Impl::Win32::model_new("model-en");
  my $recognizer = Speech::Recognition::Vosk::Impl::Win32::recognizer_new($model, 44100);

  binmode STDIN, ':raw';

  while( ! eof(*STDIN)) {
      read(STDIN, my $buf, 3200);
      my $complete = Speech::Recognition::Vosk::Impl::Win32::recognizer_accept_waveform($recognizer, $buf);
      my $spoken;
      if( $complete ) {
          $spoken = Speech::Recognition::Vosk::Impl::Win32::recognizer_result($recognizer);
      } else {
          $spoken = Speech::Recognition::Vosk::Impl::Win32::recognizer_partial_result($recognizer);
      }

      my $info = decode_json($spoken);
      if( $info->{text}) {
          print $info->{text},"\n";
      } else {
          local $| = 1;
          print $info->{partial}, "\r";
      };
  }

  # Flush the buffers
  my $spoken = Speech::Recognition::Vosk::Impl::Win32::recognizer_final_result($recognizer);
  my $info = decode_json($spoken);
  print $info->{text},"\n";

=head1 FUNCTIONS

=cut
