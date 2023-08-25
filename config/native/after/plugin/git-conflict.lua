require('konrad.git-conflict').setup({
    highlights = {
        current = 'diffAdded',
        incoming = 'diffChanged',
        ancestor = 'diffRemoved',
    },
})
