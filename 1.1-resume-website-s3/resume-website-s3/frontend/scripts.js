// Paste all JS from <script>...</script> in index.html.tpl here
// Backend URL - this variable will be replaced with the actual backend URL
var backend_url = "${backend_api_url}";

// Mobile menu toggle
if (document.querySelector('.menu-toggle')) {
    document.querySelector('.menu-toggle').addEventListener('click', function() {
        document.querySelector('nav ul').classList.toggle('active');
    });
}

// Close mobile menu when clicking on a link
if (document.querySelectorAll('nav ul li a')) {
    document.querySelectorAll('nav ul li a').forEach(link => {
        link.addEventListener('click', () => {
            document.querySelector('nav ul').classList.remove('active');
        });
    });
}

// Update visitor count
async function updateVisitorCount() {
    try {
        const apiUrl = backend_url + '/visitor';
        const response = await fetch(apiUrl);
        const data = await response.json();
        document.getElementById('visitorCount').textContent = data.count;
        if (location.hash === '#admin') {
            document.getElementById('analyticsSection').style.display = 'block';
            renderVisitorChart(data.count);
        }
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        document.getElementById('visitorCount').textContent = 'Error';
    }
}

// Contact form submission
if (document.getElementById('contactForm')) {
    document.getElementById('contactForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = {
            name: document.getElementById('name').value,
            email: document.getElementById('email').value,
            message: document.getElementById('message').value
        };
        try {
            const response = await fetch(backend_url + '/contact', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });
            const result = await response.json();
            document.getElementById('formStatus').textContent = 
                response.ok ? 'Message sent successfully!' : `Error: $${result.error}`;
            document.getElementById('formStatus').style.color = response.ok ? 'green' : 'red';
            if (response.ok) {
                document.getElementById('contactForm').reset();
                setTimeout(() => {
                    document.getElementById('formStatus').textContent = '';
                }, 3000);
            }
        } catch (error) {
            document.getElementById('formStatus').textContent = 'Error sending message.';
            document.getElementById('formStatus').style.color = 'red';
            console.error('Error:', error);
        }
    });
}

// Render visitor chart
function renderVisitorChart(count) {
    const ctx = document.getElementById('visitorChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['January', 'February', 'March', 'April', 'May', 'June'],
            datasets: [{
                label: 'Monthly Visitors',
                data: [count/2, count/3, count/1.5, count/1.2, count/1.1, count],
                backgroundColor: 'rgba(52, 152, 219, 0.2)',
                borderColor: 'rgba(52, 152, 219, 1)',
                borderWidth: 2,
                tension: 0.3,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            },
            plugins: {
                legend: {
                    labels: {
                        font: {
                            size: 14
                        }
                    }
                }
            }
        }
    });
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    updateVisitorCount();
});
