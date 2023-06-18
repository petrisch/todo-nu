use std assert
use std assert equal
use std assert skip
use ./tn.nu

export def test_get_project_context_filter [] {

    let ALL_WORKITEMS = [
                        '- [x] Test complete',
                        '- [ ] Test incomplete',
                        '- [o] Test partcomplete',
                        '- [ ] Test incomplete +projectx',
                        '- [x] Test complete @contexty'
    		    ]

    # assert equal ($ALL_WORKITEMS.3) '- [ ] Test incomplete +projectx'
    let a = (tn get_project_context_filter $ALL_WORKITEMS '' '')

    assert equal $a $ALL_WORKITEMS 
    #TODO test project, context, which should deliver $ALL_WORKITEMS.3
    # But gives a type string like: |4| - [ ] Test invomplete +projectx |
    # let a = (tn get_project_context_filter $ALL_WORKITEMS 'projectx' '')
}

# Just for seeing that the test works
export def test_version [] {
    let version_string = "version"
    assert equal (tn version_string $version_string) $version_string
}

export def test_skip [] {
    assert skip
}
