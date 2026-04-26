document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("message-form")
  if (!form) return

  form.addEventListener("submit", async (e) => {
    e.preventDefault()

    const formData = new FormData(form)

    const response = await fetch(form.action, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })

    if (response.ok) {
      form.reset()
    } else {
      const data = await response.json()
      alert(data.errors.join("\n"))
    }
  })
})