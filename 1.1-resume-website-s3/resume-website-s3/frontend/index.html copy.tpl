<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>John Doe - Full Stack Developer</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --primary: #2c3e50;

            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>John Doe - Full Stack Developer</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                <link rel="stylesheet" href="styles.css">
                <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
            </head>
            <body>
                <!-- Header Partial -->
                {% include 'header.html.tpl' %}

                <!-- Main Content Partial -->
                {% include 'main.html.tpl' %}

                <!-- Footer Partial -->
                {% include 'footer.html.tpl' %}

                <script src="scripts.js"></script>
            </body>
            </html>
            font-size: 1.8rem;
            font-weight: 700;
        }
        
        .logo span {
            color: var(--accent);
        }
        
        nav ul {
            display: flex;
            list-style: none;
        }
        
        nav ul li {
            margin-left: 1.5rem;
        }
        
        nav ul li a {
            color: white;
            font-weight: 500;
            padding: 0.5rem 0;
            position: relative;
        }
        
        nav ul li a:after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: 0;
            left: 0;
            background-color: var(--accent);
            transition: var(--transition);
        }
        
        nav ul li a:hover:after {
            width: 100%;
        }
        
        .menu-toggle {
            display: none;
            font-size: 1.5rem;
            cursor: pointer;
        }
        
        /* Hero Section */
        .hero {
            background: linear-gradient(rgba(44, 62, 80, 0.8), rgba(44, 62, 80, 0.8)), url('https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1500&q=80');
            background-size: cover;
            background-position: center;
            color: white;
            padding: 5rem 0;
            text-align: center;
        }
        
        .hero-content {
            max-width: 800px;
            margin: 0 auto;
        }
        
        .hero h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        
        .hero p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
        }
        
        .btn {
            display: inline-block;
            background: var(--secondary);
            color: white;
            padding: 0.8rem 1.5rem;
            border-radius: 50px;
            font-weight: 600;
            transition: var(--transition);
            border: none;
            cursor: pointer;
        }
        
        .btn:hover {
            background: var(--accent);
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        
        /* Section Styles */
        section {
            padding: 5rem 0;
        }
        
        .section-title {
            text-align: center;
            margin-bottom: 3rem;
        }
        
        .section-title h2 {
            font-size: 2.5rem;
            color: var(--primary);
            position: relative;
            display: inline-block;
            padding-bottom: 0.5rem;
        }
        
        .section-title h2:after {
            content: '';
            position: absolute;
            width: 50%;
            height: 3px;
            background: var(--secondary);
            bottom: 0;
            left: 25%;
        }
        
        /* About Section */
        #about {
            background-color: white;
        }
        
        .about-content {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 2rem;
        }
        
        .about-text {
            flex: 1;
            min-width: 300px;
        }
        
        .about-img {
            flex: 1;
            min-width: 300px;
            text-align: center;
        }
        
        .about-img img {
            max-width: 100%;
            border-radius: 10px;
            box-shadow: var(--shadow);
        }
        
        /* Skills Section */
        #skills {
            background-color: var(--light);
        }
        
        .skills-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
        }
        
        .skill-category {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: var(--shadow);
            transition: var(--transition);
        }
        
        .skill-category:hover {
            transform: translateY(-5px);
        }
        
        .skill-category h3 {
            color: var(--primary);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
        }
        
        .skill-category h3 i {
            margin-right: 0.5rem;
            color: var(--secondary);
        }
        
        .skill-list {
            list-style: none;
        }
        
        .skill-list li {
            padding: 0.5rem 0;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .skill-list li:last-child {
            border-bottom: none;
        }
        
        .skill-level {
            width: 60%;
            height: 8px;
            background: #eee;
            border-radius: 10px;
            overflow: hidden;
        }
        
        .skill-level span {
            display: block;
            height: 100%;
            background: var(--secondary);
            border-radius: 10px;
        }
        
        /* Projects Section */
        #projects {
            background-color: white;
        }
        
        .projects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
        }
        
        .project-card {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: var(--shadow);
            transition: var(--transition);
        }
        
        .project-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        
        .project-img {
            height: 200px;
            overflow: hidden;
        }
        
        .project-img img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: var(--transition);
        }
        
        .project-card:hover .project-img img {
            transform: scale(1.05);
        }
        
        .project-info {
            padding: 1.5rem;
        }
        
        .project-info h3 {
            color: var(--primary);
            margin-bottom: 0.5rem;
        }
        
        .project-info p {
            color: var(--text-light);
            margin-bottom: 1rem;
        }
        
        .project-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .project-tags span {
            background: var(--light);
            color: var(--primary);
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        /* Contact Section */
        #contact {
            background-color: var(--light);
        }
        
        .contact-container {
            display: flex;
            flex-wrap: wrap;
            gap: 2rem;
        }
        
        .contact-info {
            flex: 1;
            min-width: 300px;
        }
        
        .contact-info h3 {
            color: var(--primary);
            margin-bottom: 1.5rem;
        }
        
        .contact-details {
            list-style: none;
        }
        
        .contact-details li {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .contact-details li i {
            width: 40px;
            height: 40px;
            background: var(--secondary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
        }
        
        .contact-form {
            flex: 1;
            min-width: 300px;
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: var(--shadow);
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-family: inherit;
            font-size: 1rem;
        }
        
        .form-group textarea {
            min-height: 150px;
            resize: vertical;
        }
        
        /* Visitor Counter */
        .visitor-counter {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: var(--shadow);
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .visitor-counter h3 {
            color: var(--primary);
            margin-bottom: 0.5rem;
        }
        
        #visitorCount {
            font-size: 2rem;
            font-weight: 700;
            color: var(--secondary);
        }
        
        /* Analytics Section */
        #analyticsSection {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: var(--shadow);
            margin-top: 2rem;
        }
        
        .chart-container {
            position: relative;
            height: 300px;
            margin-top: 1rem;
        }
        
        /* Footer */
        footer {
            background: var(--dark);
            color: white;
            text-align: center;
            padding: 2rem 0;
        }
        
        .social-links {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin: 1.5rem 0;
        }
        
        .social-links a {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
        }
        
        .social-links a:hover {
            background: var(--secondary);
            transform: translateY(-3px);
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .menu-toggle {
                display: block;
            }
            
            nav ul {
                position: fixed;
                top: 70px;
                left: -100%;
                width: 100%;
                height: calc(100vh - 70px);
                background: var(--primary);
                flex-direction: column;
                align-items: center;
                justify-content: center;
                transition: var(--transition);
            }
            
            nav ul.active {
                left: 0;
            }
            
            nav ul li {
                margin: 1.5rem 0;
            }
            
            .hero h1 {
                font-size: 2.5rem;
            }
            
            .section-title h2 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <div class="container header-container">
            <div class="logo">John<span>Doe</span></div>
            <div class="menu-toggle">
                <i class="fas fa-bars"></i>
            </div>
            <nav>
                <ul>
                    <li><a href="#about">About</a></li>
                    <li><a href="#skills">Skills</a></li>
                    <li><a href="#projects">Projects</a></li>
                    <li><a href="#contact">Contact</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container hero-content">
            <h1>Full Stack Developer & Cloud Engineer</h1>
            <p>I build scalable web applications and cloud infrastructure with modern technologies</p>
            <a href="#contact" class="btn">Get In Touch</a>
        </div>
    </section>

    <!-- About Section -->
    <section id="about">
        <div class="container">
            <div class="section-title">
                <h2>About Me</h2>
            </div>
            <div class="about-content">
                <div class="about-text">
                    <p>Hello! I'm John Doe, a passionate full-stack developer with expertise in JavaScript, Python, and cloud technologies. I enjoy building efficient, scalable applications that solve real-world problems.</p>
                    <p>With over 5 years of experience in the tech industry, I've worked on various projects ranging from small business websites to enterprise-level applications. I'm always eager to learn new technologies and take on challenging projects.</p>
                    <p>When I'm not coding, you can find me hiking, reading tech blogs, or contributing to open-source projects. I believe in writing clean, maintainable code and following best practices in software development.</p>
                </div>
                <div class="about-img">
                    <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="John Doe">
                </div>
            </div>
        </div>
    </section>

    <!-- Skills Section -->
    <section id="skills">
        <div class="container">
            <div class="section-title">
                <h2>My Skills</h2>
            </div>
            <div class="skills-container">
                <div class="skill-category">
                    <h3><i class="fas fa-code"></i> Frontend</h3>
                    <ul class="skill-list">
                        <li>JavaScript <div class="skill-level"><span style="width: 90%;"></span></div></li>
                        <li>React <div class="skill-level"><span style="width: 85%;"></span></div></li>
                        <li>HTML/CSS <div class="skill-level"><span style="width: 95%;"></span></div></li>
                    </ul>
                </div>
                <div class="skill-category">
                    <h3><i class="fas fa-server"></i> Backend</h3>
                    <ul class="skill-list">
                        <li>Python <div class="skill-level"><span style="width: 88%;"></span></div></li>
                        <li>Node.js <div class="skill-level"><span style="width: 80%;"></span></div></li>
                        <li>Express <div class="skill-level"><span style="width: 85%;"></span></div></li>
                    </ul>
                </div>
                <div class="skill-category">
                    <h3><i class="fas fa-cloud"></i> Cloud & DevOps</h3>
                    <ul class="skill-list">
                        <li>AWS <div class="skill-level"><span style="width: 85%;"></span></div></li>
                        <li>Terraform <div class="skill-level"><span style="width: 75%;"></span></div></li>
                        <li>Docker <div class="skill-level"><span style="width: 80%;"></span></div></li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- Projects Section -->
    <section id="projects">
        <div class="container">
            <div class="section-title">
                <h2>My Projects</h2>
            </div>
            <div class="projects-grid">
                <div class="project-card">
                    <div class="project-img">
                        <img src="https://images.unsplash.com/photo-1551650975-87deedd944c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="E-commerce Platform">
                    </div>
                    <div class="project-info">
                        <h3>E-commerce Platform</h3>
                        <p>A full-stack e-commerce solution with React frontend and Node.js backend</p>
                        <div class="project-tags">
                            <span>React</span>
                            <span>Node.js</span>
                            <span>MongoDB</span>
                        </div>
                        <a href="#" class="btn">View Project</a>
                    </div>
                </div>
                <div class="project-card">
                    <div class="project-img">
                        <img src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="Cloud Infrastructure">
                    </div>
                    <div class="project-info">
                        <h3>Cloud Infrastructure</h3>
                        <p>Terraform modules for automated AWS infrastructure deployment</p>
                        <div class="project-tags">
                            <span>Terraform</span>
                            <span>AWS</span>
                            <span>CI/CD</span>
                        </div>
                        <a href="#" class="btn">View Project</a>
                    </div>
                </div>
                <div class="project-card">
                    <div class="project-img">
                        <img src="https://images.unsplash.com/photo-1550439062-609e1531270e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="Task Management App">
                    </div>
                    <div class="project-info">
                        <h3>Task Management App</h3>
                        <p>A productivity application with real-time updates and team collaboration</p>
                        <div class="project-tags">
                            <span>Vue.js</span>
                            <span>Firebase</span>
                            <span>WebSockets</span>
                        </div>
                        <a href="#" class="btn">View Project</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Visitor Counter -->
    <div class="container">
        <div class="visitor-counter">
            <h3>Visitor Count</h3>
            <p><span id="visitorCount">Loading...</span> people have visited this site</p>
        </div>
    </div>

    <!-- Contact Section -->
    <section id="contact">
        <div class="container">
            <div class="section-title">
                <h2>Contact Me</h2>
            </div>
            <div class="contact-container">
                <div class="contact-info">
                    <h3>Get In Touch</h3>
                    <ul class="contact-details">
                        <li>
                            <i class="fas fa-envelope"></i>
                            <span>john.doe@example.com</span>
                        </li>
                        <li>
                            <i class="fas fa-phone"></i>
                            <span>+1 (123) 456-7890</span>
                        </li>
                        <li>
                            <i class="fas fa-map-marker-alt"></i>
                            <span>San Francisco, CA</span>
                        </li>
                    </ul>
                </div>
                <div class="contact-form">
                    <form id="contactForm">
                        <div class="form-group">
                            <label for="name">Name</label>
                            <input type="text" id="name" required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" required>
                        </div>
                        <div class="form-group">
                            <label for="message">Message</label>
                            <textarea id="message" required></textarea>
                        </div>
                        <button type="submit" class="btn">Send Message</button>
                        <p id="formStatus"></p>
                    </form>
                </div>
            </div>
        </div>
    </section>

    <!-- Analytics Section -->
    <div class="container">
        <div id="analyticsSection" style="display: none;">
            <div class="section-title">
                <h2>Website Analytics</h2>
            </div>
            <div class="chart-container">
                <canvas id="visitorChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <div class="container">
            <div class="social-links">
                <a href="#"><i class="fab fa-github"></i></a>
                <a href="#"><i class="fab fa-linkedin"></i></a>
                <a href="#"><i class="fab fa-twitter"></i></a>
                <a href="#"><i class="fab fa-dev"></i></a>
            </div>
            <p>&copy; 2023 John Doe. All rights reserved.</p>
        </div>
    </footer>


    
    <script>
        // Backend URL - this variable will be replaced with the actual backend URL
        var backend_url = "${backend_api_url}";
        
        // Mobile menu toggle
        document.querySelector('.menu-toggle').addEventListener('click', function() {
            document.querySelector('nav ul').classList.toggle('active');
        });
        
        // Close mobile menu when clicking on a link
        document.querySelectorAll('nav ul li a').forEach(link => {
            link.addEventListener('click', () => {
                document.querySelector('nav ul').classList.remove('active');
            });
        });
        
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
                    
                    // Clear status message after 3 seconds
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
    </script>
</body>
</html>