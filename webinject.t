use diagnostics;
use warnings;
use strict;
use Test::More qw( no_plan );

#http://www.drdobbs.com/scripts-as-modules/184416165
do './webinject.pl';

#
# GLOBAL TEST SETUP
#

before_test();

#
#
# get_testnum_display
#
#

is(get_testnum_display(5,1), '5', 'get_testnum_display: Standard');
is(get_testnum_display(5,2), '10005', 'get_testnum_display: 1st repeat');
is(get_testnum_display(5,3), '20005', 'get_testnum_display: 2nd repeat');

$main::case{runon}='PROD';
is(get_test_step_skip_message(), 'run on PROD', 'get_test_step_skip_message: run on PROD');

$main::case{runon}='PAT';
is(get_test_step_skip_message(), 'run on PAT', 'get_test_step_skip_message: run on PAT');

#
#
# _url_path
#
#

is(_url_path('https://example.com/search/form?terms=cheapest'), '/search/form', '_url_path: Full url with query string');

#
#
# save_page_when_method_post_and_has_action 
#
#

before_test();
$main::response = HTTP::Response->parse('A response without an action');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('ACTION none', 'save_page_when_method_post_and_has_action : ACTION none');

before_test();
$main::response = HTTP::Response->parse('A response with an action after post - method="post" id="3" action="submit.aspx"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('ACTION submit.aspx', 'save_page_when_method_post_and_has_action : ACTION after method of post');

before_test();
$main::response = HTTP::Response->parse('A response with an action before post - action="submit.aspx" id="3" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('ACTION submit.aspx', 'save_page_when_method_post_and_has_action : ACTION before method of post');

before_test();
$main::response = HTTP::Response->parse('A response with a null action - action="" id="3" method="post"');
save_page_when_method_post_and_has_action ();
is(stdout_contains('ACTION IS NULL'), 1, 'save_page_when_method_post_and_has_action : ACTION IS NULL');
assert_stdout_contains('SAVING /jobs/search.cgi', 'save_page_when_method_post_and_has_action : default action to page path');

before_test();
$main::response = HTTP::Response->parse('A response with full url in action="https://example.com/home/query.cgi?keyword=test" method="post"');
save_page_when_method_post_and_has_action ();
is(stdout_contains('ACTION https:'), 1, 'save_page_when_method_post_and_has_action : full url in action');
assert_stdout_contains('SAVING /home/query.cgi', 'save_page_when_method_post_and_has_action : clean action to just url path');

before_test();
$main::response = HTTP::Response->parse('action="submit.aspx" id="3" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('NO CACHED PAGES', 'save_page_when_method_post_and_has_action : NO CACHED PAGES');

before_test();
$main::response = HTTP::Response->parse('action="submit.aspx" id="3" method="post"');
save_page_when_method_post_and_has_action ();
save_page_when_method_post_and_has_action ();
assert_stdout_contains('MATCH at position 0', 'save_page_when_method_post_and_has_action : MATCH at position 0');

before_test();
$main::response = HTTP::Response->parse('action="submit.aspx" id="3" method="post"');
save_page_when_method_post_and_has_action ();
$main::response = HTTP::Response->parse('action="query.aspx" id="3" method="post"');
save_page_when_method_post_and_has_action ();
save_page_when_method_post_and_has_action ();
assert_stdout_contains('MATCH at position 1', 'save_page_when_method_post_and_has_action : MATCH at position 1');

before_test();
$main::response = HTTP::Response->parse('action="submit.aspx" method="post"');
save_page_when_method_post_and_has_action ();
$main::response = HTTP::Response->parse('action="query.aspx" method="post"');
save_page_when_method_post_and_has_action ();
$main::response = HTTP::Response->parse('action="/register.cgi" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('NO MATCH on 0:submit.aspx', 'save_page_when_method_post_and_has_action : NO MATCH on 0:submit.aspx');
assert_stdout_contains('NO MATCH on 1:query.aspx', 'save_page_when_method_post_and_has_action : NO MATCH on 1:query.aspx');
assert_stdout_contains('NO MATCHES FOUND IN CACHE', 'save_page_when_method_post_and_has_action : NO MATCHES FOUND IN CACHE - different action');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('MATCH at position 2', 'save_page_when_method_post_and_has_action : MATCH at position 2');
$main::response = HTTP::Response->parse('action="/submit.aspx" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('NO MATCHES FOUND IN CACHE', 'save_page_when_method_post_and_has_action : NO MATCHES FOUND IN CACHE - slightly different action');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('MATCH at position 3', 'save_page_when_method_post_and_has_action : MATCH at position 3 - slightly different action saved again');



before_test();
$main::response = HTTP::Response->parse('action="index_0" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Index 0 is free', 'save_page_when_method_post_and_has_action : Index 0 is free');

$main::response = HTTP::Response->parse('action="index_1" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Index 1 is free', 'save_page_when_method_post_and_has_action : Index 1 is free');

$main::response = HTTP::Response->parse('action="index_2" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Index 2 is free', 'save_page_when_method_post_and_has_action : Index 2 is free');

$main::response = HTTP::Response->parse('action="index_3" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Index 3 is free', 'save_page_when_method_post_and_has_action : Index 3 is free');

$main::response = HTTP::Response->parse('action="index_4" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Index 4 is free', 'save_page_when_method_post_and_has_action : Index 4 is free');

$main::response = HTTP::Response->parse('action="index_5" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Index 5 is free', 'save_page_when_method_post_and_has_action : Index 5 is free');

$main::response = HTTP::Response->parse('action="page_7" method="post"');
clear_stdout();
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Overwriting - Oldest Page Index: 0', 'save_page_when_method_post_and_has_action : Overwrite oldest page in cache - index 0');

$main::response = HTTP::Response->parse('action="page_8" method="post"');
clear_stdout();
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Overwriting - Oldest Page Index: 1', 'save_page_when_method_post_and_has_action : Overwrite oldest page in cache - index 1');

$main::response = HTTP::Response->parse('action="page_9" method="post"');
clear_stdout();
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Overwriting - Oldest Page Index: 2', 'save_page_when_method_post_and_has_action : Overwrite oldest page in cache - index 2');

clear_stdout();
save_page_when_method_post_and_has_action ();
assert_stdout_contains('MATCH at position 2', 'save_page_when_method_post_and_has_action : MATCH at position 2 - save overwritten page again');

$main::response = HTTP::Response->parse('action="page_8" method="post"');
clear_stdout();
save_page_when_method_post_and_has_action ();
assert_stdout_contains('MATCH at position 1', 'save_page_when_method_post_and_has_action : MATCH at position 1 - save older overwritten page again');
assert_stdout_contains('Cache 0:page_7', 'save_page_when_method_post_and_has_action : saved in cache at 0');
assert_stdout_contains('Cache 1:page_8', 'save_page_when_method_post_and_has_action : saved in cache at 1');
assert_stdout_contains('Cache 2:page_9', 'save_page_when_method_post_and_has_action : saved in cache at 2');
assert_stdout_contains('Cache 3:index_3', 'save_page_when_method_post_and_has_action : saved in cache at 3');
assert_stdout_contains('Cache 4:index_4', 'save_page_when_method_post_and_has_action : saved in cache at 4');
assert_stdout_contains('Cache 5:index_5', 'save_page_when_method_post_and_has_action : saved in cache at 5');



before_test();
$main::response = HTTP::Response->parse('action="submit.aspx" method="post"');
save_page_when_method_post_and_has_action ();
assert_stdout_contains('Saved [\d\.]+:submit.aspx', 'save_page_when_method_post_and_has_action : confirmation page is saved');

#
#
# auto_sub
#
#

before_test();
auto_sub('a=b&c=d&e=f', 'normalpost', 'http://example.com');
assert_stdout_contains('There are 3 fields in the postbody', 'auto_sub : normal post has 3 fields');

before_test();
auto_sub('', 'normalpost', 'http://example.com');
assert_stdout_contains('There are 0 fields in the postbody', 'auto_sub : normal post has 0 fields');

before_test();
auto_sub('a=b', 'normalpost', 'http://example.com');
assert_stdout_contains('There are 1 fields in the postbody', 'auto_sub : normal post has 1 field');

before_test();
auto_sub("( 'name' => 'Upload' )", 'multipost', 'http://example.com');
assert_stdout_contains('There are 1 fields in the postbody', 'auto_sub : multi post has 1 field');

before_test();
auto_sub("( 'fileUpload' => ['examples/multipart_post.csv'], 'name' => 'Upload' )", 'multipost', 'http://example.com');
assert_stdout_contains('There are 1 fields in the postbody', 'auto_sub : multi post has 2 fields');

before_test();
auto_sub('a=b&c=d&e=f', 'normalpost', 'http://example.com');
assert_stdout_contains('Field 1: a=b', 'auto_sub : field 1 display');
assert_stdout_contains('Field 2: c=d', 'auto_sub : field 2 display');
assert_stdout_contains('Field 3: e=f', 'auto_sub : field 3 display');

before_test();
auto_sub("(  'a' => 'b', 'c' => 'd', 'e' => 'f' )", 'multipost', 'http://example.com');
assert_stdout_contains(q|Field 1: \(  'a' => 'b|, 'auto_sub : multipost field 1 display');
assert_stdout_contains(q|Field 2:  'c' => 'd|, 'auto_sub : multimpost field 2 display');
assert_stdout_contains(q|Field 3:  'e' => 'f|, 'auto_sub : multimpost field 3 display'); #'

before_test();
is(auto_sub('a=b&c=d&e=f', 'normalpost', 'http://example.com'), 'a=b&c=d&e=f', 'auto_sub : no change - no cached pages');
assert_stdout_contains('REMOVE PATH', 'auto_sub : remove path');
assert_stdout_contains('DESPERATE MODE - NO ANCHOR', 'auto_sub : desperate mode - no anchor');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post"');
save_page_when_method_post_and_has_action ();
auto_sub('a=b&c=d&e=f', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('MATCH at position 0', 'auto_sub : exact action match - assert 1');
assert_stdout_does_not_contain('PAGE NAME ONLY', 'auto_sub : exact action match - assert 2');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post"');
save_page_when_method_post_and_has_action ();
auto_sub('a=b&c=d&e=f', 'normalpost', 'http://example.com/premium/search.aspx');
assert_stdout_contains('MATCH at position 0', 'auto_sub : page name only - assert 2');
assert_stdout_contains('REMOVE PATH', 'auto_sub : page name only - assert 2');
assert_stdout_does_not_contain('DESPERATE MODE', 'auto_sub : page name only - assert 3');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post"');
save_page_when_method_post_and_has_action ();
auto_sub('a=b&c=d&e=f', 'normalpost', 'http://example.com/premium/search');
assert_stdout_contains('MATCH at position 0', 'auto_sub : desperate mode - assert 2');
assert_stdout_contains('DESPERATE MODE', 'auto_sub : desperate mode - assert 2');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" name="a" type="hidden" value="bee bee"');
save_page_when_method_post_and_has_action ();
auto_sub('a={DATA}&c=d&e=f', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('ID MATCH 0', 'auto_sub : ID MATCH');
assert_stdout_contains('Normal field a has \{DATA\}', 'auto_sub : normal field has {DATA}');
assert_stdout_contains('DATA is bee', 'auto_sub : normalpost {DATA} - field 1 - assert 1');
assert_stdout_contains('URLESCAPE!!', 'auto_sub : normalpost {DATA} - field 1 - assert 2');
assert_stdout_contains('SUBBED FIELD is a=bee%20bee', 'auto_sub : normalpost {DATA} - field 1 - assert 3');
assert_stdout_contains('a=bee%20bee', 'auto_sub : normalpost {DATA} - field 1 - assert 4');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" <input name="c" value="dee" /> <input name="e" value="eff" />');
save_page_when_method_post_and_has_action ();
auto_sub('a=b&c={DATA}&e={DATA}', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('c=dee', 'auto_sub : normalpost {DATA} - field 2');
assert_stdout_contains('e=eff', 'auto_sub : normalpost {DATA} - field 3');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" name="a" type="hidden" value="bee bee"');
save_page_when_method_post_and_has_action ();
auto_sub("(  'a' => '{DATA}', 'c' => 'd', 'e' => 'f' )", 'multipost', 'http://example.com/search.aspx');
assert_stdout_contains('ID MATCH 0', 'auto_sub : ID MATCH');
assert_stdout_contains('Multi field a has \{DATA\}', 'auto_sub : multi field has {DATA}');
assert_stdout_contains('DATA is bee', 'auto_sub : multipost {DATA} - field 1 - assert 1');
assert_stdout_contains(q|SUBBED FIELD is \(  'a' => 'bee bee|, 'auto_sub : multipost {DATA} - field 1 - assert 2'); #'
assert_stdout_contains(q|POSTBODY is \(  'a' => 'bee bee', 'c' => 'd', 'e' => 'f' \)|, 'auto_sub : multipost {DATA} - field 1 - assert 3');
assert_stdout_contains('Auto substitution latency was ', 'auto_sub : latency display');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" <input name="c" value="dee" /> <input name="e" value="eff" />');
save_page_when_method_post_and_has_action ();
auto_sub(q|(  'a' => 'b', 'c' => '{DATA}', 'e' => '{DATA}' )|, 'multipost', 'http://example.com/search.aspx');
assert_stdout_contains(q|'c' => 'dee'|, 'auto_sub : multipost {DATA} - field 2');
assert_stdout_contains(q|'e' => 'eff'|, 'auto_sub : multipost {DATA} - field 3');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" name="Row1_Col1_Field1" type="hidden" value="b"');
save_page_when_method_post_and_has_action ();
auto_sub('Row1_{NAME}_Field1=b&c=d&e=f', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('LHS of \{NAME}: \[Row1_] ', 'auto_sub : normal post - LHS of {NAME}');
assert_stdout_contains('RHS of \{NAME}: \[_Field1] ', 'auto_sub : normal post - RHS of {NAME}');
assert_stdout_contains('NAME is Col1', 'auto_sub : normal post - NAME is');
assert_stdout_contains('SUBBED NAME is Row1_Col1_Field1=b', 'auto_sub : normal post - SUBBED NAME is');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" <input name="Row2_Col2_Field2" value="d" /> <input name="Row3_Col3_Field3" value="f" /> ');
save_page_when_method_post_and_has_action ();
auto_sub('Row1_Col1_Field1=b&Row2_{NAME}_Field2=d&Row3_{NAME}_Field3=f', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('NAME is Col2', 'auto_sub : normal post - NAME is - field 2');
assert_stdout_contains('NAME is Col3', 'auto_sub : normal post - NAME is - field 2');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" name="Row1_Col1_Field1" type="hidden" value="b"');
save_page_when_method_post_and_has_action ();
auto_sub('{NAME}_Field1=b&c=d&e=f', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('LHS of \{NAME}: \[] ', 'auto_sub : LHS of {NAME} is null');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" name="Row1_Col1_Field1" type="hidden" value="b"');
save_page_when_method_post_and_has_action ();
auto_sub('Row1_Col1_{NAME}=b&c=d&e=f', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('RHS of \{NAME}: \[] ', 'auto_sub : RHS of {NAME} is null');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" <input name="Row2_Col2_Field2" value="d" /> <input name="Row3_Col3_Field3" value="f" /> ');
save_page_when_method_post_and_has_action ();
auto_sub(q|(  'a' => 'b', 'Row2_{NAME}_Field2' => '{DATA}', '{NAME}Field3' => '{DATA}' )|, 'multipost', 'http://example.com/search.aspx');
assert_stdout_contains(q|POSTBODY is \(  'a' => 'b', 'Row2_Col2_Field2' => 'd', 'Row3_Col3_Field3' => 'f' \)|, 'auto_sub : multi post - NAME and DATA');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" <input name="strange_xname" value="d" /> <input name="odd_yname" value="f" /> ');
save_page_when_method_post_and_has_action ();
auto_sub(q|(  'a' => 'b', '{NAME}_xname.x' => '{DATA}', '{NAME}_yname.y' => '{DATA}' )|, 'multipost', 'http://example.com/search.aspx');
assert_stdout_contains('DOTx found in ', 'auto_sub : NAME - DOTX');
assert_stdout_contains('DOTy found in ', 'auto_sub : NAME - DOTY');
assert_stdout_contains(q|DOTx restored to  'strange_xname.x'|, 'auto_sub : NAME - DOTX restored');
assert_stdout_contains(q|DOTy restored to  'odd_yname.y'|, 'auto_sub : NAME - DOTY restored');
assert_stdout_contains(q|POSTBODY is \(  'a' => 'b', 'strange_xname.x' => 'd', 'odd_yname.y' => 'f' \)|, 'auto_sub : DOTX and DOTY');

before_test();
$main::response = HTTP::Response->parse('action="/search.aspx" method="post" <input name="odd_xname" value="default" /> <input name="odd_yname" value="default" /> ');
save_page_when_method_post_and_has_action ();
auto_sub('a=b&{NAME}xname.x=d.xtra&{NAME}yname.y=f.ytra', 'normalpost', 'http://example.com/search.aspx');
assert_stdout_contains('odd_xname\.x=d\.xtra', 'auto_sub : DOTX - ensure value not affected');
assert_stdout_contains('odd_yname\.y=f\.ytra', 'auto_sub : DOTY - ensure value not affected');

#
# GLOBAL HELPER SUBS
#

sub contains {
    my ($_string, $_target) = @_;
    return $_string =~ m/$_target/s;
}

sub stdout_contains {
    my ($_target) = @_;
    return $main::results_stdout =~ m/$_target/s;
}

sub assert_stdout_contains {
    my ($_must_contain, $_test_description) = @_;
    if ($main::results_stdout =~ m/$_must_contain/s) {
        is(1, 1, $_test_description);
    } else {
        is($main::results_stdout, $_must_contain, $_test_description);
    }
}

sub assert_stdout_does_not_contain {
    my ($_must_not_contain, $_test_description) = @_;
    if ($main::results_stdout =~ m/$_must_not_contain/s) {
        isnt($main::results_stdout, $main::results_stdout, $_test_description);
        print '# not expected: '.$_must_not_contain."\n";
    } else {
        is(1, 1, $_test_description);
    }
}

sub clear_stdout {
    $main::results_stdout = '';
}

sub before_test {
    $main::EXTRA_VERBOSE = 1;

    $main::case{url} = 'http://example.com/jobs/search.cgi?query=Test%Automation&Location=London';
    $main::results_stdout = '';
    $main::response = '';

    undef @main::cached_pages;
    undef @main::cached_page_actions;
    undef @main::cached_page_update_times;
    
    return;
}

#
# SUPPRESS WARNINGS FOR VARIABLES USED ONLY ONCE
#

$main::response = '';
$main::EXTRA_VERBOSE = 0;
$main::results_stdout = '';
undef @main::cached_pages;
undef @main::cached_page_actions;
undef @main::cached_page_update_times;
