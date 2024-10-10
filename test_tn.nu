use std assert
# use std "assert equal"
# use std "assert skip"

#[test]
def test_addition [] {
    assert equal (1 + 2) 3
}

#[test]
def test_get_project_context_filter [] {

    export use tn.nu *

    let ALL_WORKITEMS = [
                        '- [x] Test complete',
                        '- [ ] Test incomplete',
                        '- [o] Test partcomplete',
                        '- [ ] Test incomplete +projectx',
                        '- [x] Test complete @contexty'
    		    ]
    # assert equal (get_project_context_filter $ALL_WORKITEMS 'projectx' none) $ALL_WORKITEMS.3
    assert equal (get_project_context_filter $ALL_WORKITEMS 'projectx' '') '│ 3 │ - [ ] Test incomplete +projectx │'
    assert equal (get_project_context_filter $ALL_WORKITEMS 'projectx' 'contexty') [$ALL_WORKITEMS.3 $ALL_WORKITEMS.4]
}

#[test]
def test_replace_with_glyth [] {
    let todos = ['- [x', '- [ ]', '- [o]']
    let expected = '[😀, 😏, 🤔]'
    let return = (replace_with_glyth $todos)

    std assert ($return == $expected) $"expected ($expected), got: ($return)"
    # --error-label {
    #     start: (metadata $todos).span.start,
    #     end: (metadata $todos).span.end,
    #     text: $"(todos) is not an even number",
    #     }
}

#[test]
#[ignore]
def test_skip [] {
   print 'dont'
}
