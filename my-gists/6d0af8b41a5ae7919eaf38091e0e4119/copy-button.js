document.addEventListener('readystatechange', (event) => {
  let loaded = false

  if (
    loaded === false
    && (
      event.target.readyState === 'interactive'
      || event.target.readyState === 'complete'
    )
  ) {
    document.querySelectorAll('[data-js~="copy"]').forEach(element => element.addEventListener('click', event => {
      let target = event.currentTarget
      let subject

      if (
        target.dataset.jsCopy !== undefined
        && document.querySelector(target.dataset.jsCopy) !== null
      ) {
        let otherTarget = document.querySelector(target.dataset.jsCopy)

        if (target.dataset.js.includes('copy-html')) {
          target = otherTarget.innerHTML
        } else {
          target = otherTarget
        }
      }

      if (target.dataset.js && target.dataset.js.includes('copy-html')) {
        subject = target.innerHTML
      } else {
        if (target.tagName.toLowerCase() === 'textarea') {
          subject = target.value
          target = target.parentElement
        } else {
          subject = target.innerText
        }
      }

      navigator.clipboard.writeText(subject.trim())
        .then(() => {
          event.target.classList.add('copied')
          setTimeout(() => event.target.classList.remove('copied'), 2200)
        })
        .catch(e => console.error(e))
    }))

    loaded = true
  }
})
