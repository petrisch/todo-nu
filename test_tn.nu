use std "assert"
use std "assert equal"
use std "assert skip"

export def test_get_project_context_filter [] {

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

export def test_skip [] {
    assert skip
}
