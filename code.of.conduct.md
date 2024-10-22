# HONESTI: Saropa’s Code of Conduct

> The Ultimate Developer’s Handbook: Code Quality, Ethics, and Performance at Saropa

<!-- markdownlint-disable MD033 - Disable No HTML -->
<img src="https://raw.githubusercontent.com/saropa/saropa_dart_utils/main/SaropaLogo2019_contrast-1200.png" alt="saropa company logo" style="filter: drop-shadow(0.2em 0.2em 0.13em rgba(68, 68, 68, 0.35));" width="340" />

As an organization, Saropa promotes behavior that reflects our values. This Code of Conduct outlines the minimum standards expected of our staff, contributors, and business partners. Compliance with the most restrictive applicable laws and regulations is required.

## Introduction

Welcome to the team. This guide provides essential insights and best practices to help developers maintain high standards of integrity, efficiency, and collaboration in their work.

1. *Harmony*: Focus on writing clean, maintainable, and well-documented code.
1. *Openness*: Emphasize honest progress reporting and clear communication.
1. *Networking*: Highlight the importance of teamwork and effective documentation.
1. *Education*: Encourage ongoing growth and staying updated with new technologies.
1. *Streamlining*: Use tools to identify bottlenecks and optimize code performance effectively.
1. *Technology*: Utilize AI tools wisely, ensuring thorough review and understanding their limitations.
1. *Integrity*: Maintain ethical practices and manage stress to foster a healthy work environment.

## Our Pledge

We pledge to create a harassment-free experience for everyone in our project and community, regardless of age, body size, disability, ethnicity, gender identity, level of experience, education, socio-economic status, nationality, personal appearance, race, religion, or sexual identity and orientation.

*Positive behavior includes:*

- Using inclusive language and respecting differing viewpoints and experiences
- Accepting constructive criticism gracefully and focusing on the community's best interests
- Showing empathy towards others

Saropa is committed to diversity and equal opportunity. We do not discriminate based on race, creed, color, ethnicity, national origin, religion, sex, sexual orientation, gender identity, age, height, weight, disability (including HIV status), veteran status, military obligations, or marital status. This policy applies to all employees, volunteers, clients, and contractors.

*Unacceptable behavior includes:*

- Use of sexualized language or imagery, trolling, or derogatory comments
- Publishing others' private information without permission
- Any inappropriate conduct in a professional setting

This Code of Conduct applies within project spaces and public spaces when representing the project or community. This includes using official emails, social media accounts, or acting as an official representative.

Report unacceptable behavior to the project team at [code_of_conduct@saropa.com](code_of_conduct@saropa.com). All complaints will be reviewed and investigated confidentially. Failure to enforce the Code of Conduct may result in repercussions as determined by the project's leadership.

### We Start Now

> If there is anything that follows that you do not understood clearly or agree with, then you must ask about it. You will be measured against each of these guidelines and held accountable. This is a contract code of conduct that we demand of ourselves.

### Table Of Contents

- [Introduction](#introduction)
- [Our Pledge](#our-pledge)
  - [We Start Now](#we-start-now)
  - [Table Of Contents](#table-of-contents)
- [1. Harmony](#1-harmony)
  - [1.2. Write Clean, Maintainable, and Well-documented code](#11-write-clean-maintainable-and-well-documented-code)
  - [1.3. Respect Our Users](#12-respect-our-users)
  - [1.4. Future-Proof](#13-future-proof)
  - [1.5. Defensive Programming No Fragile Code](#14-defensive-programming-no-fragile-code)
- [2. Openness](#2-openness)
  - [2.1. Honest Prototyping](#21-honest-prototyping)
  - [2.2. Completion Transparency](#22-completion-transparency)
  - [2.3. Reliable Estimates](#23-reliable-estimates)
  - [2.4. Avoid False Claims](#24-avoid-false-claims)
  - [2.5. Understand “Production-Ready”](#25-understand-production-ready)
- [3. Networking](#3-networking)
  - [3.1. Collaboration](#31-collaboration)
  - [3.2. Encouraging Questions](#32-encouraging-questions)
  - [3.3. Put Yourself in Users’ Shoes](#33-put-yourself-in-users-shoes)
  - [3.4. Effective Documentation](#34-effective-documentation)
- [4. Education](#4-education)
  - [4.1. Continuous Learning and Improvement](#41-continuous-learning-and-improvement)
  - [4.2. Code Reviews](#42-code-reviews)
  - [4.3. Testing](#43-testing)
  - [4.4. Documentation Updates](#44-documentation-updates)
- [5. Streamlining](#5-streamlining)
  - [5.1. Measure](#51-measure)
  - [5.2. Unnecessary Calculations](#52-unnecessary-calculations)
  - [5.3. Efficient Structures and Algorithms](#53-efficient-structures-and-algorithms)
  - [5.4. Asynchronous Operations](#54-asynchronous-operations)
  - [5.5. Minimize Memory](#55-minimize-memory)
  - [5.6. Cache](#56-cache)
- [6. Technology](#6-technology)
  - [6.1. AI as an Accelerator](#61-ai-as-an-accelerator)
  - [6.2. AI for Documentation](#62-ai-for-documentation)
  - [6.3. AI Limitations](#63-ai-limitations)
  - [6.4. Language](#64-language)
- [7. Integrity](#7-integrity)
  - [7.1. Recognize and Manage Stress](#71-recognize-and-manage-stress)
  - [7.2. Identifying and Managing Risks](#72-identifying-and-managing-risks)
  - [7.3. Managing Panic](#73-managing-panic)
  - [7.4. Respect Flow State](#74-respect-flow-state)
  - [7.5. Celebrate Diversity and Stamp Out Bullying](#75-celebrate-diversity-and-stamp-out-bullying)
  - [7.6. Honesty with Stakeholders](#76-honesty-with-stakeholders)
  - [7.7. Joy in Programming](#77-joy-in-programming)
- [The Survey](#the-survey)
- [The Exercise](#the-exercise)

## 1 Harmony

Bad coding is easy. The following rules make code simpler to read, review, maintain, and test. Maintain clean, maintainable, and well-documented code. Follow naming conventions, prevent fragile code, be future-proof, and practice defensive programming.

### 1.1. Write Clean, Maintainable, and Well-documented code

*(a)* 🌈 Use consistent and meaningful names for variables, functions, and classes. Avoid abbreviations and ensure names are descriptive of their purpose.

``` dart
    /// Use clear and descriptive names
    void fetchDataFromServer() {}

    /// Use “db” for database operations
    void dbFetchUser() {}

    /// Use “api” prefix for web calls
    void apiFetchData() {}

    /// Combine nouns and verbs clearly
    List<String> getUserList() {}

    /// Use “is” prefix for boolean variables
    bool isLoading = true;
```

*(b)* 📐 Maintain a separation of concerns. Small files and functions streamline code reviews, migrations and merges.

- Separate UI, models, services, and utilities into distinct folders, with patterns like `MVVM` or `Clean Architecture`.
- Keep state management logic separate from UI code, to ensure state changes are predictable and testable.
- Organize files by feature or module, named based on their functionality

*(c)* 🎯 Exit early to avoid nested ifs and separate logic into methods

*BEFORE*: Succinct but difficult to read

``` dart
void checkAge(int age) {
   String result = '';

  if (age >= 18) {
    if (age < 65) {
      result = 'You are an adult.';
    } else {
      result = 'You are a senior citizen.';
    }
  } else {
    if (age < 2) {
      result = 'You are a baby.';
    } else if (age < 13) {
      result = 'You are a child.';
    } else {
      result = 'You are a teenager.';
    }
  }

  return result;
}
```

*AFTER*: exit early, separated concerns, validate params, give more options

``` dart
String checkAge(int age) {
  final ageDisplayValue = getAgeDisplayValue(age);
  if (ageDisplayValue == null) {
    return 'Invalid age';
  }

  return 'You are a $ageDisplayValue.';
}

String? getAgeDisplayValue(int age) {
  if (age < 0) {
    return null;
  } else if (age < 2) {
    return 'baby';
  } else if (age < 13) {
    return 'child';
  } else if (age < 18) {
    return 'teenager';
  } else if (age < 65) {
    return 'adult';
  } else {
   return 'senior citizen';
  }
}
```

### 1.2. Respect Our Users

> Companies that mishandle sensitive user data face severe legal and reputation consequences. Never risk unauthorized access or data breaches.

*(a)* 🚨 Never log sensitive user information - even to the user's device. Implement hashing strategies or encrypted in all outputs.
*(b)* 🥇 Prevent accidents by applying consistent theming and respect accessibility across all UI components.
*(c)* 🏆 Always obtain explicit permission before collecting or sharing user data, regardless of its perceived importance or financial value. Clearly communicate your data practices and ensure users understand the implications of their choices.

### 1.3. Future-Proof

*(a)* 💣 Do not write code that will cause issues in the future, such as hard-coded dates or temporary fixes.
*(b)* 🏗️ Plan for the long-term maintainability and scalability of your code.
*(c)* ⚙️ Use configuration files or environment variables instead of hard-coding values.
*(d)* 💎 *Zero* warnings, hacks, or lints. And to-dos need to go in project management tools, never source.

### 1.4. Defensive Programming (No Fragile Code)

*(a)* 🐛 Implement thorough error handling to *gracefully* manage edge cases and unexpected situations.
*(b)* ⚠️ Ensure that all inputs are validated and sanitized

- Empty and null string checks simplify operations and clarify debugging
- Ensure indices don't exceed minimum / maximum allowed value (bound errors)
- Validate inputs to prevent malicious characters or invalid data.

> SQL injection, XSS, CSRF, buffer overflow, command injection, DoS, man-in-the-middle attacks, session hijacking are common examples of malicious inputs that can compromise application security.

*(c)* 💾 Avoid optimistic casting and utilize null safety features to avoid null errors

```dart
  // Optimistic casting (avoid) will *error* if the provided data in missing or a different format
  final nameError = jsonData['name'] as String;

  // Safe casting with `!`:
  final name = jsonData['name'] as String?;
  if (name == null || name.isEmpty) {
    // log or ignore
  } else {
    // do something
  }
```

*(d)* 🧯 Avoid shortcuts that may lead to code breaking under unusual conditions.

- Handle exceptions within the method without throwing errors - unless the needed for parental logging.
- Log errors somewhere they can be review, but be mindful or leaking sensitive data

## 2 Openness

Be transparent about your progress, skills, and contributions. Provide realistic estimates, update them regularly, and avoid false claims.

### 2.1. Honest Prototyping

*(a)* 📝 Don’t present prototypes as final, production-ready code. Set the right expectations with stakeholders to prevent misunderstandings and false hopes about the readiness of a feature.

*(b)* 💡 Use prototypes for innovation — to explore ideas and test solutions, without investing too much time or resources.

*(c)* 🗣️ Seek feedback on prototypes to refine and improve.Involve team members and stakeholders early to gather diverse perspectives and iterate on the design based on constructive feedback.

### 2.2. Completion Transparency

*(a)* 📅 Do not claim to have completed a task if you do not fully understand it. This avoids potential errors and ensures quality.If you encounter difficulties, be upfront about them and seek assistance.

*(b)* 🆘 Seek help or clarification when needed to ensure the task is done correctly.Don't be afraid to ask questions or request guidance from more experienced colleagues; it's a vital part of learning.

*(c)* 🎨 Report your progress and any issues encountered. Keep detailed records to track progress, identify recurring problems, and facilitate smoother handoffs.

### 2.3. Reliable Estimates

*(a)* ⏰ Provide realistic estimates for your tasks and projects.Break down tasks into small, manageable components and note potential obstacles when estimating.

*(b)* 🔄 Regularly update estimates as work progresses and new information becomes available. This helps manage expectations and allows for better planning and resource allocation.

*(c)* 📢 Promptly communicate any changes in timelines to keeping stakeholders informed. This builds trust and allows for adjustments in project planning.

### 2.4. Avoid False Claims

*(a)* ❌ Do not falsely claim credit for work you did not do or abilities you do not possess. Integrity is crucial for trust within your team and with stakeholders. Be clear about your contributions.

*(b)* 🔦 Recognize and celebrate your achievements, but also acknowledge the contributions of others. Transparency fosters a healthy and collaborative work environment.

*(c)* 🌱 Seek opportunities to learn and grow. Regularly assess your skills and identify areas for improvement. Pursue training, attend workshops, and seek mentorship to develop expertise.

### 2.5. Understand “Production-Ready”

*(a)* ⚙️ Production-ready code is stable, well-tested, and optimized. Ensure your code has passed all necessary tests and can handle expected load.

*(b)* 🐞 Conduct thorough testing to identify and fix bugs before deployment. Provide comprehensive documentation for smooth deployment and maintenance.

## 3. Networking

Work well with your team, communicate clearly, encourage questions, and put yourself in users' shoes. Maintain effective documentation.

### 3.1. Collaboration

*(a)* 🤝 Share knowledge and supporting everyone in your team. Foster an environment of mutual respect and cooperation where everyone feels valued and heard.

*(b)* 🗣️ Communicate clearly and effectively about your progress, challenges, and needs. Use regular updates and status meetings to keep everyone on the same page.

*(c)* 🗨️ Provide constructive feedback and be open to receiving feedback. Embrace feedback as a tool for growth, ensuring it is given respectfully and constructively.

### 3.2. Encouraging Questions

*(a)* 📱 Foster an environment where asking questions is encouraged and valued. Make it clear that there are no “stupid” questions and that curiosity drives improvement.

*(b)* 🗺️ Remember that seeking help is a sign of strength and a commitment to quality. Encourage team members to seek clarification to ensure tasks are completed accurately.

*(c)* 🤗 Provide mentorship and support to junior developers. Share your knowledge generously to help others grow, fostering a culture of continuous learning.

### 3.3. Put Yourself in Users’ Shoes

*(a)* 🕺 Consider the practicality and usability of features from the user's perspective. Think about how users will interact with your product and prioritize their needs.

- Similar elements should behave in similar ways and be located in familiar places to ensure predictability and intuitiveness.
- Group information hierarchically, hide complexity under "more" options, and use filters and search functionalities to make it manageable.
- Utilize labels, color, buttons, and diagrams, and incorporate accessibility features to enhance usability.
- Always provide a warning before performing any irreversible actions.
- Regularly ask users for their input to ensure the product meets their needs and expectations.

*(b)* 👂 Ask questions and seek clarification to ensure the final product meets the user's needs. Engage with users through surveys and feedback sessions to gather insights.

*(c)* 📋 Gather feedback from users to understand their needs and preferences. Use this feedback to refine and enhance your product, ensuring it aligns with user expectations.

### 3.4. Effective Documentation

> If you have to explain something about the system to another person (in a review, to client, or in any other way) then it needs better documentation. No exceptions.

*(a)* 🖋️ Use clear and concise language in all your documentation. Your audience includes both subject experts and those new to the project.

*(b)* 📑 Maintain a consistent style and structure throughout your documentation and code comments. Consistency helps everyone navigate and understand the documentation more effectively.

*(c)* 🌏 Provide examples to illustrate abstract concepts and usage expectations. This helps others apply the information correctly.

*(d)* 🆙 Why, Not How. Explain simply *why* we do something: stakeholder needs, things that went wrong, ideas, an evolved tech stack, legislation, or industry standards.

*(e)*  🎷 Integrate reviews into your project planning at milestones. Properly maintained documentation prevents confusion, reduces errors, and streamlines onboarding and training, ultimately saving time and resources.

*(f)* 🖨️ If the explanation of non-trivial logic or algorithms becomes too detailed, consider splitting the logic into separate methods or fields for better organization and reusability.

- Explain the purpose in doc headers. If a doc header is too detailed, it's a sign the method is too complex.
- Important parameters need explaining in the header.
- Use comments for complex logic (e.g., loops, nested functions)
- If the explanation becomes too detailed, the logic should be split into separate methods or fields.

> Documentation will help you write better code

## 4. Education

Stay updated with the latest technologies and best practices. Participate in code reviews, write comprehensive tests, and keep documentation up to date.

### 4.1. Continuous Learning and Improvement

*(a)* 📚 Stay updated with the latest technologies, tools, and best practices. Regularly read industry blogs, attend webinars, and participate in professional forums.

*(b)* 🛠️ Regularly review and refactor your code to improve its quality and performance. Set aside time for code refactoring sessions to keep your codebase clean and efficient.

*(c)* 🧪 Experiment with new techniques and approaches. Be open to trying new methods and tools that could enhance your work, and share successful experiments with your team.

### 4.2. Code Reviews

*(a)* 🔄 Participate actively in code reviews, both giving and receiving feedback. Code reviews are collaborative learning opportunities that improve code quality.

*(b)* 👏 Be respectful and constructive in your feedback. Focus on the code, not the coder, and aim to help improve the overall project.

*(c)* ⏰ Use code reviews as a learning opportunity. Learn from others' code, understand different approaches, and incorporate best practices into your own work.

### 4.3. Testing

*(a)* ✅ Write comprehensive tests for your code, including unit tests, integration tests, and end-to-end tests. A thorough test suite helps catch issues early and ensures the robustness of your code.

*(b)* 🛡️ Ensure your tests cover edge cases and potential failure points. Anticipate potential issues and write tests to handle those scenarios, improving code reliability.

*(c)* ♻️ Regularly run tests to catch issues early and maintain code quality. Integrate automated testing into your development workflow to ensure continuous quality checks.

### 4.4. Documentation Updates

*(a)* 🛸 Regularly review and improve documentation to keep it relevant and useful. Schedule periodic documentation reviews to ensure accuracy and completeness.

*(b)* 🧭 Solicit feedback from team members and users to identify areas for improvement. Encourage feedback on documentation to make it more user-friendly and informative.

## 5. Streamlining

Utilize tools to measure and identify areas for improvement. Avoid premature optimization: Focus on writing clear and correct code before optimizing. Strive for a zero-problem project: no warnings, no hacks, and no linting issues.

### 5.1. Measure

*(a)* 🏆 Base your optimization efforts on actual profiler data rather than assumptions. Data-driven decisions ensure that your optimization efforts are focused where they will have the most impact.

*(b)* 🎯 Focus on optimizing areas that have a significant impact on performance. Not all slow parts of your code are worth optimizing. Focus on the parts that will make a noticeable difference.

*(c)* 📏 Avoid premature optimization by writing clear and correct code first. Code must work correctly before you can make it faster, but poorly performing code is a sign of incorrectness.

### 5.2. Unnecessary Calculations

*(a)* 🧮 Minimize expensive operations and optimize data storage and retrieval.

*(b)* 📏 Delay or avoid performing calculations that aren't directly necessary for the task at hand.

*(c)* 📊 Cache results of expensive or frequent computations.

### 5.3. Efficient Structures and Algorithms

*(a)* 🛵 Different data structures and algorithms have different performance characteristics, so choose the ones that are best suited to your needs.

- Use lists for better performance and easier manipulation.
- Prefer methods for caching complex logic instead of get/set fields: This provides a clearer separation of concerns and signals the parent component to implement caching.

*(b)* ⚖️ Prefer simplicity and clarity over complexity unless performance requires otherwise. Simple code is easier to maintain and less likely to contain bugs.

*(c)* ⚙️ Optimize data access patterns to reduce latency and improve throughput. Be mindful of how often and how you access data.

### 5.4. Asynchronous Operations

*(a)* 💻 Use asynchronous techniques to your application responsive, even for long-running tasks.

- Avoid heavy computations in run-first method (e.g. build)
- Always offload complex calculations and changeable data to streaming, listening and future objects

*(b)* 🔄 Ensure proper handling of async/await to maintain responsiveness.

*(c)* 🚫 Make sure errors in async code are caught and dealt with, so they don’t cause silent failures.

### 5.5. Minimize Memory

*(a)* 🎭 Store data late and dispose early. Be mindful of explicit disposal needs (such as controllers and listeners) versus garbage disposal.

*(b)* 🧹 Properly manage memory to avoid leaks and use memory-efficient data structures to reduce your application's memory footprint.

*(c)* 💤 Use techniques like lazy loading and pagination to handle large datasets efficiently.

### 5.6. Cache

*(a)* 🦄 Implement caching mechanisms to reduce the need for frequent data retrieval and calculations. Minimize the size and frequency of data transfers, with efficient data formats and compression.

*(b)* 🧠 Avoid keeping large amounts of data in memory. Balance cache size and invalidation strategies to maintain speed without excessive memory usage.

*(c)* ♻️ Ensure cached data is correctly invalidated or updated to avoid stale data issues.

## 6. Technology

AI is used most effectively as an accelerator for experienced developers, and a drafting assistant for novices. Use AI with caution, and always review AI-generated content thoroughly.

### 6.1. AI as an Accelerator

*(a)* 📌 Experienced developers use code completion tools and LLMs to speed up coding tasks and generate boilerplate code. Use AI to explore new solutions and ideas efficiently.

*(b)* ⚠️ AI-generated code is never production-ready and should be used with caution. Always review and test AI-generated code thoroughly for fitness, reliability, and security.

### 6.2. AI for Documentation

*(a)* 🍄 Do not use AI-generated comments that merely describe how code works or to describe complex logic. Focus instead on simplifying the code to make it more readable and self-explanatory.

*(b)* 📋 AI can help articulate why code is written a certain way, providing context and rationale. Generate comments that explain design, trade-offs, and purpose, to help maintainers understand it better.

### 6.3. AI Limitations

*(a)* 🕵️ AI tools overlook critical details and make incorrect assumptions. Always perform a thorough review to ensure compliance with project requirements and standards.

*(b)* ✅ Leverage AI to generate comprehensive test cases, especially for edge scenarios that might be easily overlooked, to enhance your testing strategy and code quality.

### 6.4. Language

*(a)* 🖱️ You must actively use spelling and grammar checkers for all code and documentation. Language assistants are a vital quality control when working at speed.

## 7. Integrity

Focus on ethical practices, managing stress, identifying and handling risks, fostering joy in programming, and promoting diversity and inclusion.

### 7.1. Recognize and Manage Stress

*(a)* 🌸 Acknowledge when you're overwhelmed and talk to your team or manager. Use techniques like mindfulness, exercise, or regular breaks to maintain well-being.

*(b)* 🪜 Break large tasks into smaller, manageable pieces. Use tools like task lists or project management software to track progress.

*(c)* 🧘 Identify signs of burnout, such as chronic fatigue or lack of motivation. Encourage a culture of mental health openness and support taking time off to recharge.

### 7.2. Identifying and Managing Risks

*(a)* 🧩 Identify potential challenges early in the development process. Regularly assess your project for risks and discuss them with your team.

*(b)* 🗂️ Develop action plans for identified risks and regularly review them. This might include contingency plans or additional testing.

*(c)* 📢 Keep stakeholders updated about risks and their potential impact. Use regular status updates and meetings to keep them informed and engaged.

### 7.3. Managing Panic

*(a)* 🛑 Identify common panic triggers like tight deadlines, unexpected issues, or high-stakes presentations.

*(b)* 🧘‍♂️ Create a predefined action plan for managing panic, including pausing to breathe, assessing the situation, and using stress-reduction techniques like mindfulness and deep breathing.

*(c)* 📣 Communicate transparently with your team during panic situations, clearly articulating the issue and next steps.

*(d)* 🏡 Acknowledge that WFH presents specific challenges for training and communication, making it harder to manage and support.

*(e)* ❓ Experienced people ask questions. "I got this" is good, but "I don't know" is crucial for growth.

*(f)* 🔨 Slow progress is only bad when not communicated. Refusing to feedback bad news is neither a successful or rewarded strategy, instead ask stakeholders for creative solutions.

### 7.4. Respect Flow State

*(a)* ⚡ Flow state is a mental state of deep focus and immersion where productivity peaks and complex problems are solved more effectively.

*(b)* 🌊 Achieve flow state by choosing challenging yet manageable tasks, eliminating distractions, and focusing on one task at a time.

*(c)* 🧘 Respect your colleagues' flow state by avoiding unnecessary interruptions and using signals or tools to indicate when someone is in deep work mode.

### 7.5. Celebrate Diversity and Stamp Out Bullying

*(a)* 🌍 Recognize and address different types of bullying, including verbal, physical, social, cyberbullying, and constructive dismissal. Embrace and celebrate diversity in all its forms, including religion, sexual orientation, age, disabilities, medical needs, and family responsibilities.

*(b)* 🔍 Ensure a supportive environment where everyone feels safe and respected. Promote an inclusive culture where diversity is viewed as a strength, fostering innovation and creativity, while promptly addressing and taking action against any form of bullying.

### 7.6. Honesty with Stakeholders

*(a)* 💬 Be transparent and honest with stakeholders, users, and clients. Avoid engaging in harmful business practices such as planned obsolescence or binding practices that trap individuals in an organization.

*(b)* 🤝 Promote open communication and trust with all parties involved, ensuring that ethical standards are maintained in all business dealings.

### 7.7. Joy in Programming

*(a)* 🎉 Focus on the enjoyable aspects of your work and celebrate small victories. Cultivate a positive work environment by supporting colleagues and promoting appreciation.

*(b)* 🧠 Encourage a culture of safety and empathy. Create an environment where team members feel comfortable taking risks and making mistakes.

*(c)* ✈️ Delivering high-quality work to clients as the ultimate reward.

*(d)* 🌟 The real magic is working within a small team, achieving high standards, and succeeding together.

## The Survey

Choose 1 only...
<!-- double space needed for force newline -->
1. 🛠️ When you aim to maintain clean, maintainable code, how do you approach it?  
  ☐ Refactor regularly to improve code quality and maintainability  
  ☐ Utilize automated tools to highlight and fix code issues  
  ☐ Collaborate with peers to ensure high standards are maintained  

2. 📊 How do you ensure your progress reports are comprehensive and effective?  
  ☐ Use project management tools and write comprehensive email updates  
  ☐ Hold regular check-ins with the team and provide context with proposed solutions  
  ☐ Ensure timely communication and factual transparency to avoid surprises  

3. 📚 How do you contribute to the quality and accuracy of documentation?  
  ☐ Update documentation promptly after changes are made  
  ☐ Regularly review and provide feedback on existing documentation  
  ☐ Actively participate in documentation review sessions  

4. 🌱 How do you stay updated with new technologies and integrate them into your work?  
  ☐ Attend industry workshops and conferences to learn  
  ☐ Follow relevant blogs and publications for the latest trends  
  ☐ Experiment with new technologies in side projects  

5. 🔋 What steps do you take to optimize code performance in your projects?  
  ☐ Regularly profile and refactor code to enhance performance  
  ☐ Implement performance best practices from the start  
  ☐ Use feedback from performance testing to make improvements  

6. 🧘‍♂️ How do you manage stress during high-pressure situations at work?  
  ☐ Practice mindfulness and take regular breaks to stay balanced  
  ☐ Prioritize tasks and break them down into manageable steps  
  ☐ Seek support from colleagues and mentors when needed  

7. 🔥 A critical bug in the software is unresolved causing significant financial loss. What approach do you take?  
  ☐ Claim it was a misunderstanding of the requirements if questioned  
  ☐ Hide the problem with hard coding and plan to fix it later  
  ☐ Request a reassignment to another project before the issue is noticed  

8. 🌈 What actions do you take to promote a positive and inclusive workplace?  
  ☐ Encourage inclusive behavior and language among colleagues  
  ☐ Promptly report any incidents of harassment or discrimination  
  ☐ Actively support peers who may need assistance or encouragement  

9. ⚖️ How do you handle risks and unexpected challenges in projects?  
  ☐ Create contingency plans to prepare for potential issues  
  ☐ Regularly reassess and adjust project plans as needed  
  ☐ Discuss potential risks and challenges with the team  

10. 🌟 In a team setting, how do you ensure effective progress and contribution?  
  ☐ Regular team meetings for updates and problem-solving  
  ☐ Challenge team members while ensuring accountability  
  ☐ Assign tasks based on each member's strengths and expertise  

## The Exercise

Imagine you are part of a development team tasked with improving an existing task management system. Your goal is to propose new features that enhance the system's usability, performance, and overall effectiveness.

We’re looking for people who can think outside the box, deliver quality work quickly, and inspire innovation.

1. 🛠️ How would we identify a high-quality feature that is missing?
1. 📊 What is an interesting idea to report task progress to users?
1. 📚 How can the system detect if its information is accurate and up to date?
1. 🌱 What new technologies can we integrate?
1. ⚙️ What techniques can we use to optimize the system’s performance?
1. 🤖 How can AI be used to improve its capabilities?
1. 💬 How should the system utilize feedback from its users?

`END`
