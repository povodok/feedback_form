window.addEventListener('load', () => {
  if (document.getElementById('customFile')) {
    document.getElementById('customFile').addEventListener('change', (e) => {
      // show file name
      document.getElementsByClassName('custom-file-label')[0].innerText = e.target.files[0].name
    })
  }
})
