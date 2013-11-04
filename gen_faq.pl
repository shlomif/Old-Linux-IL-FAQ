#!/usr/bin/perl

use strict;

open I, "/home/shlomi/progs/perl/FAQ/pre-faq.html";

my ($line, @sections, %section_ids, %question_ids, @parts, $id,
         $text, $title, $put_text_in, $opening, $ending);

$opening = { 'text' => ''};
$ending = { 'text' => ''};

my $prefix = ">\\\$";
while($line = <I>)
{
    if ($line =~ /^$prefix/)
    {
        chomp($line);
        $line =~ s!^$prefix!!;

        # Put the text in the last question
        {
            $put_text_in->{'text'} = $text;
            $text = '';
        }

        
        if ($line =~ /^S/)
        {
            $line =~ s!^S!!;
            @parts = split(/:/, $line);
            $id = $parts[0];
            $title = join('', @parts[1..$#parts]);

            push @sections, ($put_text_in = { 'title' => $title, 'questions' => [] });
            $section_ids{$id} = $#sections;
        }
        elsif ($line =~ /^Q/)
        {
            $line =~ s!^Q!!;
            @parts = split(/:/, $line);
            $id = $parts[0];
            $title = join('', @parts[1..$#parts]);

            my $last_section = $sections[$#sections];
            push @{$last_section->{'questions'}}, ($put_text_in = { 'title' => $title });

            $question_ids{$id} = [$#sections, scalar(@{$last_section->{'questions'}})-1];
        }
        elsif ($line =~ /^P/)
        {
            $put_text_in = \$opening;
        }
        elsif ($line =~ /^E/)
        {
            $put_text_in = \$ending;
        }
        else
        {
            die "Incorrect formatting line:\n$prefix$line\n";
        }
    }
    else
    {
        $text .= $line;
    }
}
$put_text_in->{'text'} = $text;

close (I);

open (O, ">&STDOUT");

my ($s, $q);

print O "<HTML>\n<HEAD>\n<TITLE>Linux-IL FAQ</TITLE>\n</HEAD>\n<BODY BGCOLOR=\"#FFFFFF\">\n";

print O $opening->{'text'}, "\n";

print O "<UL>\n";
for($s=0;$s<scalar(@sections);$s++)
{
    print O "<A HREF=\"#section" . ($s+1) . "\"><B>Section " . ($s+1) . "</B> - " . $sections[$s]->{'title'} . "</A>\n";
    for($q=0;$q<scalar(@{$sections[$s]->{'questions'}});$q++)
    {
        print O (($q==0)?"<UL>":"<BR>"), "<A HREF=\"#question" . ($s+1) . "." . ($q+1) . "\">Q" . ($s+1) . "." . ($q+1) . ") " . $sections[$s]->{'questions'}->[$q]->{'title'} . "</A>\n";
    }
    print O "</UL>\n";
}
print O "</UL>\n";

print O "<HR>\n";

for($s=0;$s<scalar(@sections);$s++)
{
    print O "<A NAME=\"section" . ($s+1) . "\"></A><H2>" . $sections[$s]->{'title'} . "</H2>\n";
    print O $sections[$s]->{'text'} . "\n";
    for($q=0;$q<scalar(@{$sections[$s]->{'questions'}});$q++)
    {
        print O "<UL>\n";
        print O "<A NAME=\"question " . ($s+1) . "." . ($q+1) . "\"></A><B>Q" . ($s+1) . "." . ($q+1) . ") " . $sections[$s]->{'questions'}->[$q]->{'title'} . "</B>\n";
        print O "<BR><BR><BR><UL>\n";
        print O $sections[$s]->{'questions'}->[$q]->{'text'};
        print O "</UL>\n";
        print O "</UL>\n<BR><BR>\n";
    }

}

print O $ending->{'text'}, "\n";

print O "</BODY>\n</HTML>\n";

close(O);



