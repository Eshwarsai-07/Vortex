import { Octokit } from '@octokit/rest';
import dotenv from 'dotenv';
dotenv.config();

const octokitOptions = {};
if (process.env.GITHUB_TOKEN && !process.env.GITHUB_TOKEN.includes('your_github_personal_access_token') && process.env.GITHUB_TOKEN.trim() !== '') {
    octokitOptions.auth = process.env.GITHUB_TOKEN;
}
const octokit = new Octokit(octokitOptions);

// Fetch Repositories of a User
export const getRepos = async (req, res) => {
    const { githubProfile } = req.body;

    if (!githubProfile) {
        return res.status(400).json({ message: 'GitHub profile is required' });
    }

    try {
        const cleanUsername = githubProfile.replace(/^https?:\/\/github\.com\//, '').replace(/\/$/, '');
        const { data } = await octokit.repos.listForUser({
            username: cleanUsername,
            per_page: 100,
        });

        res.status(200).json(data);
    } catch (error) {
        console.error('Error fetching GitHub repositories:', error.message);
        const status = error.status || 500;
        const message =
            status === 404
                ? 'GitHub user not found'
                : 'Failed to fetch repositories from GitHub';
        res.status(status).json({ message });
    }
};

// Fetch Branches of a Specific Repository
export const getRepoBranches = async (req, res) => {
    const { owner, repo } = req.params;

    if (!owner || !repo) {
        return res
            .status(400)
            .json({ message: 'Owner and repository name are required' });
    }

    try {
        const { data } = await octokit.repos.listBranches({
            owner,
            repo,
        });

        res.status(200).json(data);
    } catch (error) {
        console.error('Error fetching repository branches:', error.message);
        const status = error.status || 500;
        const message =
            status === 404
                ? 'Repository not found'
                : 'Failed to fetch branches';
        res.status(status).json({ message });
    }
};
