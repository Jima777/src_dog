#include "dog_control/control/TrajectoryController.h"

#include "dog_control/hardware/ClockBase.h"
#include "dog_control/utils/CubicSpline.h"
#include "dog_control/utils/CubicSpline.h"
#include "dog_control/utils/MiniLog.h"
#include "dog_control/utils/QueueImpl.hpp"

namespace dog_control
{

namespace control
{

void TrajectoryController::Initialize(utils::ParamDictCRef dict)
{
    dt_ = ReadParOrDie(dict, PARAM_WITH_NS(update_period, control/MPC));
    traj_beg_time_ = 0;
}

void TrajectoryController::SetTorsoTrajectory(const TorsoTraj &torso_traj)
{
    unsigned int iter = 0;

    for (; iter < torso_traj.size(); iter++)
    {
        // ignore the outdated trajectory points
        if (torso_traj[iter].stamp > traj_beg_time_)
            break;
    }

    if (torso_traj.empty())
    {
        LOG(WARN) << "[TrajController] torso_traj has zero size.";
        return;
    }

    if (iter == torso_traj.size())
    {
        LOG(WARN) << "[TrajController] torso_traj is outdated.";
        return;
    }

    // Find the index of the first element in torso_traj_
    // to be replaced.
    const int index = static_cast<int>(
                (torso_traj[iter].stamp - traj_beg_time_) / dt_) + 1;

    torso_traj_.EraseTail(torso_traj_.size() - index);

    double last_time = traj_beg_time_ + (index - 1) * dt_;
    message::FloatingBaseState last_state = torso_traj_[index - 1].state;
    last_state.linear_vel = last_state.rot * last_state.linear_vel;
    last_state.rot_vel = last_state.rot * last_state.rot_vel;
    double sample_time = last_time + dt_;

    for (; iter < torso_traj.size(); iter++)
    {
        message::FloatingBaseState next_state = torso_traj[iter].state;
        next_state.linear_vel = next_state.rot * next_state.linear_vel;
        next_state.rot_vel = next_state.rot * next_state.rot_vel;
        const double next_time = torso_traj[iter].stamp;

        utils::CubicSpline trans(
                    last_time, last_state.trans, last_state.linear_vel,
                    next_time, next_state.trans, next_state.linear_vel);

        FBState cur_state;
        cur_state.rot_acc
                = (next_state.rot_vel - last_state.rot_vel)
                / (next_time - last_time);

        while(sample_time < next_time)
        {
            const double ratio
                    = (sample_time - last_time) / (next_time - last_time);

            trans.Sample(sample_time,
                         cur_state.state.trans,
                         cur_state.state.linear_vel,
                         cur_state.linear_acc);

            cur_state.state.rot = last_state.rot.slerp(ratio, next_state.rot);
            cur_state.state.rot_vel = last_state.rot_vel
                    + ratio * (next_state.rot_vel - last_state.rot_vel);

            FBState rotated_state;
            rotated_state.state.trans = cur_state.state.trans;
            rotated_state.state.rot = cur_state.state.rot;
            rotated_state.state.linear_vel
                    = cur_state.state.rot.conjugate()
                    * cur_state.state.linear_vel;
            rotated_state.state.rot_vel
                    = cur_state.state.rot.conjugate()
                    * cur_state.state.rot_vel;
            rotated_state.linear_acc
                    = cur_state.state.rot.conjugate()
                    * cur_state.linear_acc;
            rotated_state.rot_acc
                    = cur_state.state.rot.conjugate()
                    * cur_state.rot_acc;
            torso_traj_.Push(rotated_state);

            sample_time += dt_;
        }
    }
}

TrajectoryController::FBState TrajectoryController::GetTorsoPose(
        double t) const
{
    const int index = static_cast<int>((t - traj_beg_time_) / dt_);

    if (index < 0)
        return torso_traj_.Head();

    if (index >= torso_traj_.size())
        return torso_traj_.Tail();

    return torso_traj_[index];
}

void TrajectoryController::Update()
{
    boost::shared_ptr<hardware::ClockBase> clock = clock_ptr_.lock();
    CHECK(clock) << "[TrajController] clock is not set!";

    const double cur_time = clock->Time();

    // remove outdated trajectory points
    int index = static_cast<int>(
                (cur_time - traj_beg_time_) / dt_);

    traj_beg_time_ += index * dt_;

    // leave at least one element in trajectory
    if (index >= torso_traj_.size())
        index = torso_traj_.size() - 1;

    torso_traj_.EraseHead(index);
}

} /* control */

} /* dog_control */
